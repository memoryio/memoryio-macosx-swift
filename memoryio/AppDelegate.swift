//
//  AppDelegate.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/1/17.
//  Copyright © 2017 augmentous. All rights reserved.
//

import Cocoa
import MASPreferences

class AppDelegate: NSObject, NSApplicationDelegate, NSSharingServiceDelegate, NSUserNotificationCenterDelegate
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

    var _preferencesWindowController: NSWindowController!
    var preferencesWindowController: NSWindowController {
        if _preferencesWindowController == nil {
            let general = GeneralPreferencesViewController()
            let photo = PhotoPreferencesViewController()
            let gif = GifPreferencesViewController()
            let controllers = NSArray(objects: general, photo, gif)
            let title = NSLocalizedString("Preferences", comment: "Common title for Preferences window")
            _preferencesWindowController = MASPreferencesWindowController(viewControllers: controllers as! [Any], title: title)
        }
        return _preferencesWindowController
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

    func postNotification(informativeText: String, withActionBoolean hasActionButton: Bool) {
        let notification = NSUserNotification()
        notification.title = "memoryio"
        notification.informativeText = informativeText
        notification.hasActionButton = hasActionButton
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        center.removeDeliveredNotification(notification)
        if(notification.activationType == .contentsClicked)
        {
            preview()
        }
    }

    func setNSUserDefaults() {
        if !(UserDefaults.standard.object(forKey: "memoryio-mode") != nil) {
            UserDefaults.standard.set(0, forKey: "memoryio-mode")
        }
        if !(UserDefaults.standard.string(forKey: "memoryio-location") != nil) {
            let defaultPath = "\(NSHomeDirectory())\("/Pictures/memoryIO/")"
            UserDefaults.standard.set(defaultPath, forKey: "memoryio-location")
        }
        if !(UserDefaults.standard.object(forKey: "memoryio-warmup-delay") != nil) {
            UserDefaults.standard.set(2.0, forKey: "memoryio-warmup-delay")
        }
        if !(UserDefaults.standard.object(forKey: "memoryio-photo-delay") != nil) {
            UserDefaults.standard.set(0.0, forKey: "memoryio-photo-delay")
        }
        if !(UserDefaults.standard.object(forKey: "memoryio-gif-frame-delay") != nil) {
            UserDefaults.standard.set(0.20, forKey: "memoryio-gif-frame-delay")
        }
        if !(UserDefaults.standard.object(forKey: "memoryio-gif-frame-count") != nil) {
            UserDefaults.standard.set(10, forKey: "memoryio-gif-frame-count")
        }
        if !(UserDefaults.standard.object(forKey: "memoryio-gif-loop-count") != nil) {
            UserDefaults.standard.set(0, forKey: "memoryio-gif-loop-count")
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillFinishLaunching(_ notification:Notification) {
        NSUserNotificationCenter.default.delegate = self
        setNSUserDefaults() // before menu so it has defaults
        setupMenuBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @objc func quitAction() {
        NSApp.terminate(self)
    }

    @objc func aboutAction() {
        NSApplication.shared.orderFrontStandardAboutPanel(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func forceAction() {
    }

    @objc func forceActionGif() {
    }

    @objc func preview() {
        let imageView = previewWindow.contentView as! NSImageView
        imageView.image = self.lastImage
        previewWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func tweet() {
        let shareItems = ["  #memoryio", self.lastImage] as [Any]
        let service = NSSharingService(named: NSSharingService.Name.postOnTwitter)
        service?.delegate = self
        service?.perform(withItems: shareItems )
    }

    @objc func preferencesAction() {
        self.preferencesWindowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
