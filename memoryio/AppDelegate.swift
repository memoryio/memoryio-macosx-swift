//
//  AppDelegate.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/1/17.
//  Copyright © 2017 augmentous. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSSharingServiceDelegate
{
    var statusItem: NSStatusItem!
    var lastImage: NSImage {
        let path = UserDefaults.standard.string(forKey: "memoryio-location")

        let pictures = try? FileManager.default.contentsOfDirectory(at: NSURL.fileURL(withPath: path!), includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)

        let sortedContent = pictures?.sorted {
            ( file1: URL, file2: URL) -> Bool in
            let file1Date = try? file1.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
            let file2Date = try? file2.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])

            return file1Date!.contentModificationDate!.compare(file2Date!.contentModificationDate!) == ComparisonResult.orderedAscending
        }

        return NSImage(contentsOf:(sortedContent?.last)!)!
    }

    var _previewWindow: NSWindow!

    var previewWindow: NSWindow {
        if _previewWindow == nil {
            let imageView = NSImageView()
            imageView.imageScaling = .scaleProportionallyUpOrDown

            let tweetButton = NSButton(frame: NSMakeRect(0, 0, 77, 32))
            tweetButton.title = "Tweet"
            tweetButton.bezelStyle = .rounded
            tweetButton.setButtonType(.momentaryPushIn)
            tweetButton.action = #selector(tweet)
            tweetButton.target = self
            imageView.addSubview(tweetButton)

            _previewWindow = NSWindow(contentRect: NSMakeRect(0, 608, 480, 270),
                                      styleMask: NSWindow.StyleMask([.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]),
                                      backing: NSWindow.BackingStoreType.buffered, defer: true)
            _previewWindow.titlebarAppearsTransparent = true
            _previewWindow.isMovable = true
            _previewWindow.hasShadow = true
            _previewWindow.isReleasedWhenClosed = false
            _previewWindow.aspectRatio = NSMakeSize(480, 270)
            _previewWindow.contentView = imageView
        }
        return _previewWindow
    }

    lazy var applicationName:String = {
        if let bundleName = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") {
            if let bundleNameAsString = bundleName as? String {
                return bundleNameAsString
            }
            else {
                print("CFBundleName not a String!")
            }
        }
        else {
            print("CFBundleName nil!")
        }

        return NSLocalizedString("memoryio", comment:"The name of this application")
    }()

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.highlightMode = true
        statusItem.isEnabled = true
        statusItem.toolTip = "memoryIO"
        statusItem.target = self
        statusItem.image = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        let statusMenu = NSMenu()
        var newItem = NSMenuItem(title: "About", action: #selector(aboutAction), keyEquivalent: "")
        statusMenu.addItem(newItem)
        statusMenu.addItem(NSMenuItem.separator())
        newItem = NSMenuItem(title: "View Last", action: #selector(preview), keyEquivalent: "")
        statusMenu.addItem(newItem)
        newItem = NSMenuItem(title: "Force Photo", action: #selector(forceAction), keyEquivalent: "")
        statusMenu.addItem(newItem)
        newItem = NSMenuItem(title: "Force Gif", action: #selector(forceActionGif), keyEquivalent: "")
        statusMenu.addItem(newItem)
        statusMenu.addItem(NSMenuItem.separator())
        newItem = NSMenuItem(title: "Preferences", action: #selector(preferencesAction), keyEquivalent: "")
        statusMenu.addItem(newItem)
        statusMenu.addItem(NSMenuItem.separator())
        newItem = NSMenuItem(title: "Quit", action: #selector(quitAction),keyEquivalent: "")
        statusMenu.addItem(newItem)
        statusItem.menu = statusMenu
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillFinishLaunching(_ notification:Notification) {
        setupMenuBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @IBAction func quitAction(sender: AnyObject) {
        NSApp.terminate(self)
    }

    @IBAction func aboutAction(sender: AnyObject) {
        NSApplication.shared.orderFrontStandardAboutPanel(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func forceAction(sender: AnyObject) {
    }

    @IBAction func forceActionGif(sender: AnyObject) {
    }

    @IBAction func preview(sender: AnyObject) {
        let imageView = previewWindow.contentView as! NSImageView
        imageView.image = self.lastImage
        previewWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func tweet(sender: AnyObject) {
        let shareItems = ["  #memoryio", self.lastImage] as [Any]
        let service = NSSharingService(named: NSSharingService.Name.postOnTwitter)
        service?.delegate = self
        service?.perform(withItems: shareItems )
    }

    @IBAction func preferencesAction(sender: AnyObject) {
    }
}

