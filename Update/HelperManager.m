//
//  HelperManager.m
//  LifeClockOne
//
//  Created by User on 31.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "HelperManager.h"
#import "Constants.h"
#import "XMLDictionary.h"
#import "ApiManager.h"

@implementation HelperManager

+ (HelperManager*)sharedManager{
    static HelperManager * manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [HelperManager new];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {

        self.alerViewC = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [self.alerViewC addAction:action];
    }
    
    return  self;
}

+ (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    if(![HelperManager sharedManager].alerViewC.presentingViewController){
        [HelperManager sharedManager].alerViewC.title = title;
        [HelperManager sharedManager].alerViewC.message = message;
        
        UIViewController * rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [rootController presentViewController:[HelperManager sharedManager].alerViewC animated:YES completion:nil];
        }];
        
    }
}

+ (NSString*)getFirmwareUpdateURLforHardwareRevision:(int)hardwareRevision
                                    firmwareRevision:(int)firmwareRevision
                              fromManifestDictionary:(NSDictionary*)manifestDictionary
{
    NSString * urlStringFirmwareUpdate = nil;
    
    NSArray * listHardwares = [manifestDictionary objectForKey:keyHardware];
    
    for (NSDictionary * dicHardware in listHardwares) {
        //for
        NSLog(@"%@", dicHardware);
        if([[dicHardware objectForKey:keyRevision] intValue] == hardwareRevision)
        {
            id listFirmwares = [dicHardware objectForKey:keyFirmware];
            if(!listFirmwares)
                break;
            
            // Check list firmvare's revisions
            
            if([listFirmwares isKindOfClass:[NSDictionary class]])
            {
                if([[listFirmwares objectForKey:keyRevision] intValue] > firmwareRevision)
                {
                    urlStringFirmwareUpdate = [listFirmwares objectForKey:@"url"];
                }
            } else {
            
                int currentFirmwareRevValue = firmwareRevision;
                for (NSDictionary * dicFirmware in (NSArray*)listFirmwares) {
                    if([[dicFirmware objectForKey:keyRevision] intValue] > currentFirmwareRevValue)
                    {
                        urlStringFirmwareUpdate = [dicFirmware objectForKey:@"url"];
                        currentFirmwareRevValue = [[dicFirmware objectForKey:keyRevision] intValue];
                    }
                }
            }
            
            return urlStringFirmwareUpdate;
        }
    }
    
    return urlStringFirmwareUpdate;
}

- (void)updateFirmwareHardwareRevision:(int)hardwareRevision
                      firmwareRevision:(int)firmwareRevision
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSDictionary * dicManifest = [[ApiManager sharedManager] downloadManifestForURLString:constBaseURL];
        
        if(!dicManifest){
            [HelperManager showAlertMessage:NSLocalizedString(@"Empty manifest file", @"Empty manifest file")
                                  withTitle:NSLocalizedString(@"Error", @"Error")];
            return;
        }
            
        
        NSString * strUrlFirmware = [HelperManager getFirmwareUpdateURLforHardwareRevision:hardwareRevision firmwareRevision:firmwareRevision fromManifestDictionary:dicManifest];
        if(strUrlFirmware){
            strUrlFirmware = [strUrlFirmware stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            [[ApiManager sharedManager] downloadFirmware:strUrlFirmware];
            
        } else [HelperManager firmwareFlashingCodeForData:nil];
        
    });
}

+ (void)firmwareFlashingCodeForData:(NSData*)firmwareData
{
    if(!firmwareData)
        return;
    
#warning put your firmware flashing code here
    // put your firmware flashing code here
}

// Timer

- (void)setTimerUpdateHardware
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval: valueTimer
                                                  target: self
                                                selector: @selector(onTick)
                                                userInfo: nil repeats:YES];
    [self.timer fire];
}

- (void)invalidateTimers
{
    if(self.timer.valid){
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)onTick{
    NSLog(@"Tick");
    [self updateFirmwareHardwareRevision:valueHardware firmwareRevision:valueFirmware];
}


@end
