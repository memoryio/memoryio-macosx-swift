//
//  main.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/1/17.
//  Copyright © 2017 augmentous. All rights reserved.
//

import Cocoa

//https://lapcatsoftware.com/articles/working-without-a-nib-part-10.html
autoreleasepool {
    let delegate = AppDelegate()
    // NSApplication delegate is a weak reference,
    // so we have to make sure it's not deallocated.
    // In Objective-C you would use NS_VALID_UNTIL_END_OF_SCOPE
    withExtendedLifetime(delegate, {
        let application = NSApplication.shared
        application.delegate = delegate
        application.run()
        application.delegate = nil
    })
}
