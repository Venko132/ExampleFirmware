//
//  HelperManager.h
//  LifeClockOne
//
//  Created by User on 31.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HelperManager : NSObject

@property (strong, nonatomic) UIAlertController * alerViewC;
@property (weak) NSTimer *timer;

+ (HelperManager*)sharedManager;
+ (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title;

// Manifest
+ (NSString*)getFirmwareUpdateURLforHardwareRevision:(int)hardwareRevision
                                    firmwareRevision:(int)firmwareRevision
                              fromManifestDictionary:(NSDictionary*)manifestDictionary;

- (void)updateFirmwareHardwareRevision:(int)hardwareRevision
                      firmwareRevision:(int)firmwareRevision;

+ (void)firmwareFlashingCodeForData:(NSData*)firmwareData;

// Timer
- (void)setTimerUpdateHardware;
- (void)invalidateTimers;

@end
