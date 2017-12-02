//
//  GifPreferencesViewController.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/1/17.
//  Copyright © 2017 Augmentous. All rights reserved.
//

import Foundation
import MASPreferences

class GifPreferencesViewController: NSViewController, MASPreferencesViewController {
    var toolbarItemLabel: String? = "Gif"
    var toolbarItemImage: NSImage? = NSImage(named: NSImage.Name.preferencesGeneral)!

    var viewIdentifier: String = "GifPreferences"

    var frameCountText: NSTextField!
    var frameDelayText: NSTextField!
    var loopCountText: NSTextField!
    
    func makeView() -> NSView {
        let view = NSView(frame: NSMakeRect(0, 0, 388, 231))
        
        let dec = NumberFormatter()
        dec.numberStyle = .decimal
        dec.maximumFractionDigits = 1
        dec.minimumFractionDigits = 1
        
        let label = NSTextField(frame: NSMakeRect(43, 44, 302, 41))
        label.stringValue = "If count * time is less than 2.00 (seconds) it will seem speedy"
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        view.addSubview(label)
        
        let frameCountTextLabel = NSTextField(frame: NSMakeRect(43, 165, 175, 17))
        frameCountTextLabel.stringValue = "Number of pictures in Gif"
        frameCountTextLabel.isBezeled = false
        frameCountTextLabel.drawsBackground = false
        frameCountTextLabel.isEditable = false
        frameCountTextLabel.isSelectable = false
        view.addSubview(frameCountTextLabel)
        
        let integer = NumberFormatter()
        integer.numberStyle = .none
        
        frameCountText = NSTextField(frame: NSMakeRect(234, 165, 96, 22))
        frameCountText.action = #selector(frameCountDidChange)
        frameCountText.target = self
        frameCountText.becomeFirstResponder()
        frameCountText.formatter = integer
        frameCountText.stringValue = UserDefaults.standard.string(forKey: "memoryio-gif-frame-count")!
        view.addSubview(frameCountText)
        
        let frameDelayTextLabel = NSTextField(frame: NSMakeRect(43, 137, 175, 17))
        frameDelayTextLabel.stringValue = "Seconds per frame"
        frameDelayTextLabel.isBezeled = false
        frameDelayTextLabel.drawsBackground = false
        frameDelayTextLabel.isEditable = false
        frameDelayTextLabel.isSelectable = false
        view.addSubview(frameDelayTextLabel)
        
        frameDelayText = NSTextField(frame: NSMakeRect(234, 135, 96, 22))
        frameDelayText.action = #selector(frameDelayDidChange)
        frameDelayText.target = self
        frameDelayText.formatter = dec
        frameDelayText.stringValue = UserDefaults.standard.string(forKey: "memoryio-gif-frame-delay")!
        view.addSubview(frameDelayText)
        
        let loopCountTextLabel = NSTextField(frame: NSMakeRect(43, 108, 175, 17))
        loopCountTextLabel.stringValue = "Gif Loop Count"
        loopCountTextLabel.isBezeled = false
        loopCountTextLabel.drawsBackground = false
        loopCountTextLabel.isEditable = false
        loopCountTextLabel.isSelectable = false
        view.addSubview(loopCountTextLabel)
        
        loopCountText = NSTextField(frame: NSMakeRect(234, 105, 96, 22))
        loopCountText.action = #selector(loopCountDidChange)
        loopCountText.target = self
        loopCountText.formatter = dec
        loopCountText.stringValue = UserDefaults.standard.string(forKey: "memoryio-gif-loop-count")!
        view.addSubview(loopCountText)
        
        return view
    }
    
    override func loadView() {
        self.view = self.makeView()
    }
    
    @IBAction func frameCountDidChange(sender: NSTextField) {
        UserDefaults.standard.set(sender.intValue, forKey: "memoryio-gif-frame-count")
    }
    
    @IBAction func frameDelayDidChange(sender: NSTextField) {
        UserDefaults.standard.set(sender.floatValue, forKey: "memoryio-gif-frame-delay")
    }
    
    @IBAction func loopCountDidChange(sender: NSTextField) {
        UserDefaults.standard.set(sender.intValue, forKey: "memoryio-gif-loop-count")
    }
}
