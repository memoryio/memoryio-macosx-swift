//
//  DefaultsImporter.m
//  memoryio
//
//  Created by Jacob Rosenthal on 5/27/18.
//  Copyright © 2018 augmentous. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DefaultsImporter.h"

@implementation DefaultsImporter

+ (void)convertDefaults {

    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //set auto start
    NSString *launchAtLoginModern = [NSString stringWithFormat:@"%@.launchAtLogin", bundle];
    if(![defaults objectForKey:launchAtLoginModern]) {
        NSString *launchAtLoginLegacy = @"memoryio-launchatlogin";

        if([defaults objectForKey:launchAtLoginLegacy]) {
            bool last = [defaults boolForKey:launchAtLoginLegacy];
            [defaults setBool:last forKey:launchAtLoginModern];
        }else{
            [defaults setBool:YES forKey:launchAtLoginModern];
        }
    }

    //set mode
    NSString *modeModern = [NSString stringWithFormat:@"%@.mode", bundle];
    if(![defaults objectForKey:modeModern]) {
        NSString *modeLegacy = @"memoryio-mode";

        if([defaults objectForKey:modeLegacy]) {
            NSNumber *last = [defaults objectForKey:modeLegacy];
            [defaults setObject:last forKey:modeModern];
        }else{
            [defaults setObject:[NSNumber numberWithInt:0] forKey:modeModern];
        }
    }

    //set location
    NSString *locationModern = [NSString stringWithFormat:@"%@.location", bundle];
    if(![defaults objectForKey:locationModern]) {
        NSString *locationLegacy = @"memoryio-location";

        if([defaults objectForKey:locationLegacy]) {
            NSString *last = [defaults stringForKey:locationLegacy];
            [defaults setObject:last forKey:locationModern];
        }else{
            NSString *defaultPath = [NSString stringWithFormat:@"/Users/%@/Pictures/memoryIO/", NSUserName()];
            [defaults setObject:defaultPath forKey:locationModern];
        }
    }

    //set warmup delay
    NSString *warmupModern = [NSString stringWithFormat:@"%@.warmupDelay", bundle];
    if(![defaults objectForKey:warmupModern]) {
        NSString *warmupLegacy = @"memoryio-warmup-delay";

        if([defaults objectForKey:warmupLegacy]) {
            float last = [defaults floatForKey:warmupLegacy];
            [defaults setObject:[NSNumber numberWithFloat:last] forKey:warmupModern];
        }else{
            [defaults setObject:[NSNumber numberWithFloat:2.0f] forKey:warmupModern];
        }
    }

    //set photo delay
    NSString *photoDelayModern = [NSString stringWithFormat:@"%@.photoDelay", bundle];
    if(![defaults objectForKey:photoDelayModern]) {
        NSString *photoDelayLegacy = @"memoryio-photo-delay";

        if([defaults objectForKey:photoDelayLegacy]) {
            float last = [defaults floatForKey:photoDelayLegacy];
            [defaults setObject:[NSNumber numberWithFloat:last] forKey:photoDelayModern];
        }else{
            [defaults setObject:[NSNumber numberWithFloat:0.0f] forKey:photoDelayModern];
        }
    }

    NSString *mp4LengthModern = [NSString stringWithFormat:@"%@.mp4Length", bundle];
    if(![defaults objectForKey:mp4LengthModern]) {
        NSString *frameCountLegacy = @"memoryio-gif-frame-count";
        NSString *frameDelayLegacy = @"memoryio-gif-frame-delay";

        if([defaults objectForKey:frameCountLegacy] && [defaults objectForKey:frameDelayLegacy]) {
            NSNumber *frameCount = [defaults objectForKey:frameCountLegacy];
            float frameDelay = [defaults floatForKey:frameDelayLegacy];
            float mp4Length = [frameCount floatValue] * frameDelay;
            [defaults setObject:[NSNumber numberWithFloat:mp4Length] forKey:mp4LengthModern];
        }else{
            [defaults setObject:[NSNumber numberWithFloat:3.0f] forKey:mp4LengthModern];
        }
    }

}

@end
