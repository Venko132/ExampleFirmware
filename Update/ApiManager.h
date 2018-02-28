//
//  ApiManager.h
//  LifeClockOne
//
//  Created by User on 31.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^CompletionBlock)(id dicData, NSError * error);

@interface ApiManager : NSObject

@property (strong, nonatomic) AFHTTPSessionManager * networkManager;

+ (ApiManager*)sharedManager;

- (NSDictionary*)downloadManifestForURLString:(NSString *)urlString;
- (void)downloadFirmware:(NSString*)urlStringFirewale;
         //completionBlock:(CompletionBlock)completionHandler;

@end
