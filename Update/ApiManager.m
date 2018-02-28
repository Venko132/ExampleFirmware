//
//  ApiManager.m
//  LifeClockOne
//
//  Created by User on 31.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "ApiManager.h"
#import "Constants.h"
#import "XMLDictionary.h"
#import "HelperManager.h"
#import "XPathQuery.h"

@implementation ApiManager

+ (ApiManager*)sharedManager{
    static ApiManager * manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [ApiManager new];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        //NSURL * baseUrl = [NSURL URLWithString:constBaseURL];
        self.networkManager = [[AFHTTPSessionManager alloc] init];
        self.networkManager.requestSerializer   = [AFJSONRequestSerializer serializer];
#warning not recommended for production
        //self.networkManager.securityPolicy.allowInvalidCertificates = YES;
    }
    
    return  self;
}

#pragma mark - Manifest

//- (void)downloadManifestForURLString:(NSString *)urlString
//{
//    [self.networkManager GET:urlString
//                  parameters:nil
//                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//                         NSLog(@"%@", responseObject);
//                         //NSXMLParser * parser = (NSXMLParser*)responseObject;
//                         NSDictionary *hardware = [NSDictionary dictionaryWithXMLParser:(NSXMLParser*)responseObject];
//                         NSLog(@"%@", hardware);
//                     }
//                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                         
//                     }];
//}

- (NSDictionary*)downloadManifestForURLString:(NSString *)urlString
{
    __block NSXMLParser* result = nil;
    // Create a dispatch semaphore
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    self.networkManager.responseSerializer  = [AFXMLParserResponseSerializer serializer];
    NSURLSessionDataTask * task = [self.networkManager  GET:urlString
                   parameters:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                          NSLog(@"%@", responseObject);
                          result = responseObject;
                          dispatch_semaphore_signal(semaphore);
                      }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          [HelperManager showAlertMessage:error.localizedDescription withTitle:NSLocalizedString(@"Error", @"Error")];
                          dispatch_semaphore_signal(semaphore);
                      }];

    [task resume];
    
    // Block this thread until all tasks are complete
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER );
    
    NSDictionary * manifestContent = !result ? nil : [NSDictionary dictionaryWithXMLParser:result];
    
    return manifestContent;
}

- (void)downloadFirmware:(NSString*)urlStringFirewale
         //completionBlock:(CompletionBlock)completionHandler
{
    __block NSData* result = nil;
    // Create a dispatch semaphore
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    self.networkManager.responseSerializer  = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask * task = [self.networkManager  GET:urlStringFirewale
                                                 parameters:nil
                                                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                        NSLog(@"Download Firmware data");
                                                        result = responseObject;
                                                        dispatch_semaphore_signal(semaphore);
                                                    }
                                                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                        [HelperManager showAlertMessage:error.localizedDescription withTitle:NSLocalizedString(@"Error", @"Error")];
                                                        dispatch_semaphore_signal(semaphore);
                                                    }];
    
    [task resume];
    
    // Block this thread until all tasks are complete
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER );
    
    [HelperManager firmwareFlashingCodeForData:result];
}








@end
