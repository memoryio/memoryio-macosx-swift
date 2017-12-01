//
//  AppDelegate.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/1/17.
//  Copyright © 2017 augmentous. All rights reserved.
//

import Cocoa

class AppDelegate:NSObject, NSApplicationDelegate
{
    var statusItem: NSStatusItem!

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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillFinishLaunching(_ notification:Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

}

