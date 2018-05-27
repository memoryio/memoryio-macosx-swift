//
//  GeneralPreferencesViewController.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/1/17.
//  Copyright © 2017 Augmentous. All rights reserved.
//

import Foundation
import LaunchAtLogin

class GeneralPreferencesViewController: NSViewController {
    var toolbarItemLabel: String? = "General"
    var toolbarItemImage: NSImage? = NSImage(named: NSImage.Name.preferencesGeneral)!
    
    var viewIdentifier: String = "GeneralPreferences"

    var startupButton: NSButton!
    var locationPull: NSPopUpButton!
    var modePull: NSPopUpButton!
    var photoDelayText: NSTextField!
    
    enum LocationValue : UInt {
        case Default = 0
        case Other
        case User
    }
    
    enum ModeValue : UInt {
        case Photo = 0
        case Mp4
    }
    
    func makeView() -> NSView {
        let view = NSView(frame: NSMakeRect(0, 0, 388, 231))

        let dec = NumberFormatter()
        dec.numberStyle = .decimal
        dec.maximumFractionDigits = 2
        dec.minimumFractionDigits = 2
        dec.minimum = 0
        dec.maximum = 10
        dec.allowsFloats = true

        let locationPullLabel = NSTextField(frame: NSMakeRect(90, 166, 150, 17))
        locationPullLabel.stringValue = "Save location"
        locationPullLabel.isBezeled = false
        locationPullLabel.drawsBackground = false
        locationPullLabel.isEditable = false
        locationPullLabel.isSelectable = false
        view.addSubview(locationPullLabel)

        locationPull = NSPopUpButton(frame: NSMakeRect(270, 166, 174, 22))
        locationPull.bezelStyle = .rounded
        locationPull.action = #selector(setLocation)
        locationPull.target = self
        populateLocation()
        view.addSubview(locationPull)

        let modePullLabel = NSTextField(frame: NSMakeRect(90, 125, 150, 17))
        modePullLabel.stringValue = "Action at lockscreen"
        modePullLabel.isBezeled = false
        modePullLabel.drawsBackground = false
        modePullLabel.isEditable = false
        modePullLabel.isSelectable = false
        view.addSubview(modePullLabel)

        modePull = NSPopUpButton(frame: NSMakeRect(270, 125, 73, 22))
        modePull.bezelStyle = .rounded
        modePull.action = #selector(setMode)
        modePull.target = self
        
        modePull.addItem(withTitle: "photo")
        modePull.addItem(withTitle: "mp4")
        modePull.selectItem(at: UserDefaults.standard.integer(forKey: "\(Bundle.main.bundleIdentifier!).mode"))

        view.addSubview(modePull)

        let photoDelayTextLabel = NSTextField(frame: NSMakeRect(90, 84, 140, 17))
        photoDelayTextLabel.stringValue = "Delay after startup (s)"
        photoDelayTextLabel.isBezeled = false
        photoDelayTextLabel.drawsBackground = false
        photoDelayTextLabel.isEditable = false
        photoDelayTextLabel.isSelectable = false
        view.addSubview(photoDelayTextLabel)

        photoDelayText = NSTextField(frame: NSMakeRect(270, 84, 54, 22))
        photoDelayText.action = #selector(photoDidChange)
        photoDelayText.cell?.sendsActionOnEndEditing = true
        photoDelayText.target = self
        photoDelayText.becomeFirstResponder()
        photoDelayText.formatter = dec
        photoDelayText.stringValue = UserDefaults.standard.string(forKey: "\(Bundle.main.bundleIdentifier!).photoDelay")!

        view.addSubview(photoDelayText)

        startupButton = NSButton(frame: NSMakeRect(90, 43, 112, 18))
        startupButton.title = "Run at startup"
        startupButton.setButtonType(NSButton.ButtonType.switch)
        startupButton.action = #selector(startupAction)
        startupButton.target = self
        if LaunchAtLogin.isEnabled {
            startupButton.state = .on
            UserDefaults.standard.set(true, forKey: "\(Bundle.main.bundleIdentifier!).launchAtLogin")
        }else {
            startupButton.state = .off
            UserDefaults.standard.set(false, forKey: "\(Bundle.main.bundleIdentifier!).launchAtLogin")
        }
        view.addSubview(startupButton)

        return view
    }
    
    override func loadView() {
        self.view = self.makeView()
    }
    
    @IBAction func startupAction(sender: AnyObject) {
        if sender.state == .on {
            LaunchAtLogin.isEnabled = true
            UserDefaults.standard.set(true, forKey: "\(Bundle.main.bundleIdentifier!).launchAtLogin")
        } else {
            LaunchAtLogin.isEnabled = false
            UserDefaults.standard.set(false, forKey: "\(Bundle.main.bundleIdentifier!).launchAtLogin")
        }
    }
    
    @IBAction func setLocation(sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == 1 {
            
            let openPanel = NSOpenPanel();
            openPanel.showsResizeIndicator=true;
            openPanel.canChooseDirectories = true;
            openPanel.canChooseFiles = false;
            openPanel.allowsMultipleSelection = false;
            openPanel.canCreateDirectories = true;
            
            openPanel.begin { (result) -> Void in
                if(result == NSApplication.ModalResponse.OK){
                    let path = openPanel.url!.path
                    UserDefaults.standard.set(path + "/", forKey: "\(Bundle.main.bundleIdentifier!).location")
                }
                self.populateLocation()
            }
        }
    }
    
    @IBAction func setMode(sender: NSPopUpButton) {
        UserDefaults.standard.set(sender.indexOfSelectedItem, forKey: "\(Bundle.main.bundleIdentifier!).mode")
    }
    
    @IBAction func photoDidChange(sender: NSTextField) {
        UserDefaults.standard.set(sender.floatValue, forKey: "\(Bundle.main.bundleIdentifier!).photoDelay")
    }
    
    func populateLocation() {
        let path = UserDefaults.standard.string(forKey: "\(Bundle.main.bundleIdentifier!).location")
        locationPull.removeAllItems()
        locationPull.addItem(withTitle: path!)
        locationPull.addItem(withTitle: "Other")
        locationPull.selectItem(at: 0)
    }
}
