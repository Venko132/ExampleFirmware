//
//  Constants.m
//  LifeClockOne
//
//  Created by User on 31.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString * const constBaseURL = @"https://s3.amazonaws.com/lcofirmware/manifest.xml";
NSString * const constFileManifestName = @"manifest.xml";
NSString * const constControllerManifestID = @"manifestStID";

NSString * const keyRevision = @"rev";
NSString * const keyHardware = @"hardware";
NSString * const keyFirmware = @"firmware";

int const valueHardware = 6;
int const valueFirmware = 0;
int const valueTimer = 24*60*60;

@end
