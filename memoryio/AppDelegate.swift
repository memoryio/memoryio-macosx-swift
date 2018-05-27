//
//  AppDelegate.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/1/17.
//  Copyright © 2017 augmentous. All rights reserved.
//

import Cocoa
import AVFoundation
import AppKit
import LaunchAtLogin

class AppDelegate: NSObject, NSApplicationDelegate, NSSharingServiceDelegate, NSUserNotificationCenterDelegate
{
    let notificationManager = NotificationManager()
    var photo = Photo()
    var recorder = Record()

    var statusItem: NSStatusItem!
    var playerLayer : AVPlayerLayer!

    var _previewWindow: NSWindow!
    var previewWindow: NSWindow {
        if _previewWindow == nil {
            let imageView = NSImageView()
            imageView.wantsLayer=true
            imageView.imageScaling = .scaleProportionallyUpOrDown

            let shareButton = NSButton(frame: NSMakeRect(0, 0, 77, 32))
            shareButton.tag = 1
            shareButton.title = "Share"
            shareButton.bezelStyle = .rounded
            shareButton.setButtonType(.momentaryPushIn)
            shareButton.action = #selector(share)
            shareButton.sendAction(on: .leftMouseDown)
            shareButton.target = self
            imageView.addSubview(shareButton)

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

            let _preferencesWindow = NSWindow(contentRect: NSMakeRect(0, 608, 480, 270),
                                      styleMask: NSWindow.StyleMask([.titled, .closable, .miniaturizable, .resizable]),
                                      backing: NSWindow.BackingStoreType.buffered, defer: true)
            _preferencesWindow.isMovable = true
            _preferencesWindow.hasShadow = true
            _preferencesWindow.isReleasedWhenClosed = false
            _preferencesWindow.aspectRatio = NSMakeSize(480, 270)

            let tabViewController = NSTabViewController()

            let general = GeneralPreferencesViewController()
            tabViewController.addChildViewController(general)
            let tabView1 = tabViewController.tabViewItem(for: general)
            tabView1?.label = "General"

            let photo = PhotoPreferencesViewController()
            tabViewController.addChildViewController(photo)
            let tabView2 = tabViewController.tabViewItem(for: photo)
            tabView2?.label = "Photo"

            let mp4 = Mp4PreferencesViewController()
            tabViewController.addChildViewController(mp4)
            let tabView3 = tabViewController.tabViewItem(for: mp4)
            tabView3?.label = "Mp4"

            _preferencesWindow.contentViewController = tabViewController

            _preferencesWindowController = NSWindowController(window:_preferencesWindow)
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
        newItem = NSMenuItem(title: "View last", action: #selector(preview), keyEquivalent: "")
        statusMenu.addItem(newItem)
        newItem = NSMenuItem(title: "Force photo", action: #selector(forceAction), keyEquivalent: "")
        statusMenu.addItem(newItem)
        newItem = NSMenuItem(title: "Force mp4", action: #selector(forceActionMp4), keyEquivalent: "")
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

    func loadLast() -> URL? {
        let path = UserDefaults.standard.string(forKey: "\(Bundle.main.bundleIdentifier!).location")

        let pictures = try? FileManager.default.contentsOfDirectory(at: NSURL.fileURL(withPath: path!), includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)

        let sortedContent = pictures?.sorted {
            ( file1: URL, file2: URL) -> Bool in
            let file1Date = try? file1.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
            let file2Date = try? file2.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])

            return file1Date!.creationDate!.compare(file2Date!.creationDate!) == ComparisonResult.orderedAscending
        }

        return (sortedContent?.last)!
    }

    func setupNotifications() {
        notificationManager.subscribePowerNotifications()
        notificationManager.subscribeDisplayNotifications()

        notificationManager.notificationBlock = {
             ( messageType, messageArgument) in

            let delay = UserDefaults.standard.double(forKey: "\(Bundle.main.bundleIdentifier!).photoDelay")
            let mode = UserDefaults.standard.integer(forKey: "\(Bundle.main.bundleIdentifier!).mode")

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                if(mode == 0) {
                    self.takePhoto()
                }else{
                    self.takeMp4()
                }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillFinishLaunching(_ notification:Notification) {
        NSUserNotificationCenter.default.delegate = self
        //before menu so it has defaults
        //https://github.com/memoryio/memoryio-macosx-swift/issues/3
        DefaultsImporter.convertDefaults()
        setupMenuBar()
        setupNotifications()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func takeMp4(){
        let length = UserDefaults.standard.double(forKey: "\(Bundle.main.bundleIdentifier!).mp4Length")
        let path = UserDefaults.standard.string(forKey: "\(Bundle.main.bundleIdentifier!).location")

        _ = recorder.captureMp4Asynchronously(path: path!, withLength: length, completionHandler:{
            (error, url) -> Void in

            if error != nil {
                self.postNotification(informativeText: "There was a problem taking that shot :(", withActionBoolean: false)
            } else {
                self.postNotification(informativeText: "Well, Look at you!", withActionBoolean: true)
            }
        })
    }

    func takePhoto(){

        let warmupDelay = UserDefaults.standard.double(forKey: "\(Bundle.main.bundleIdentifier!).warmupDelay")
        let path = UserDefaults.standard.string(forKey: "\(Bundle.main.bundleIdentifier!).location")

        photo.captureStillImageAsynchronously(path: path!, warmupDelay:warmupDelay, completionHandler:{
            (error, url) -> Void in

            if((error) != nil){
                self.postNotification(informativeText: "There was a problem taking that shot :(", withActionBoolean: false)
            }else{
                self.postNotification(informativeText: "Well, Look at you!", withActionBoolean: true)
            }
        })
    }

    @objc func quitAction() {
        NSApp.terminate(self)
    }

    @objc func aboutAction() {
        NSApplication.shared.orderFrontStandardAboutPanel(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func forceAction() {
        takePhoto()
    }

    @objc func forceActionMp4() {
        takeMp4()
    }

    @objc func preview() {

        let imageView = previewWindow.contentView as! NSImageView

        //remove any old players
        if(playerLayer != nil){
            playerLayer.removeFromSuperlayer()
        }

        let lasturl = loadLast()
        switch lasturl?.pathExtension{
        case "jpg"?:
            imageView.image = NSImage(contentsOf:lasturl!)!
            break;
        case "mp4"?:
            imageView.image = nil
            let player = AVPlayer(url: lasturl!)
            player.play()
             playerLayer = AVPlayerLayer(player: player)
            playerLayer.zPosition = -1
            playerLayer.frame=(imageView.bounds)
            imageView.layer?.addSublayer(playerLayer)
            break
        default:
            break
        }

        previewWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func share() {
        let shareItems = ["#memoryio", loadLast()!] as [Any]
        let sharingPicker:NSSharingServicePicker = NSSharingServicePicker.init(items: shareItems)
        sharingPicker.show(relativeTo: (previewWindow.contentView?.viewWithTag(1)?.frame)!, of: previewWindow.contentView!, preferredEdge: NSRectEdge.minY)
    }

    @objc func preferencesAction() {
        self.preferencesWindowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
