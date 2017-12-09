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
        dec.maximumFractionDigits = 1
        dec.minimumFractionDigits = 1

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
        modePull.selectItem(at: UserDefaults.standard.integer(forKey: "memoryio-mode"))

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
        photoDelayText.target = self
        photoDelayText.becomeFirstResponder()
        photoDelayText.formatter = dec
        photoDelayText.stringValue = UserDefaults.standard.string(forKey: "memoryio-photo-delay")!

        view.addSubview(photoDelayText)

        startupButton = NSButton(frame: NSMakeRect(90, 43, 112, 18))
        startupButton.title = "Run at startup"
        startupButton.setButtonType(NSButton.ButtonType.switch)
        startupButton.action = #selector(startupAction)
        startupButton.target = self
        if UserDefaults.standard.bool(forKey: "memoryio-launchatlogin") {
            startupButton.state = .on
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
        } else {
            LaunchAtLogin.isEnabled = false
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
                    UserDefaults.standard.set(path + "/", forKey: "memoryio-location")
                }
                self.populateLocation()
            }
        }
    }
    
    @IBAction func setMode(sender: NSPopUpButton) {
        UserDefaults.standard.set(sender.indexOfSelectedItem, forKey: "memoryio-mode")
    }
    
    @IBAction func photoDidChange(sender: NSTextField) {
        UserDefaults.standard.set(sender.floatValue, forKey: "memoryio-photo-delay")
    }
    
    func populateLocation() {
        let path = UserDefaults.standard.string(forKey: "memoryio-location")
        locationPull.removeAllItems()
        locationPull.addItem(withTitle: path!)
        locationPull.addItem(withTitle: "Other")
        locationPull.selectItem(at: 0)
    }
}
