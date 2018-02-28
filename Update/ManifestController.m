//
//  ManifestController.m
//  LifeClockOne
//
//  Created by User on 31.12.15.
//  Copyright © 2015 Admin. All rights reserved.
//

#import "ManifestController.h"
#import "ApiManager.h"
#import "HelperManager.h"

@interface ManifestController ()

@end

@implementation ManifestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)actionUpdateManifest:(id)sender
{
    [[HelperManager sharedManager] updateFirmwareHardwareRevision:valueHardware firmwareRevision:valueFirmware];
}



@end
