#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "ManifestController.h"
#import "HelperManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *settingsViewConroller = [settingsStoryboard instantiateInitialViewController];
    
    settingsViewConroller.title = NSLocalizedString(@"Settings", @"Settings");
    settingsViewConroller.tabBarItem.image = [UIImage imageNamed:@"Settings"];
    
    // Manifest Controller
    UIViewController *manifestController = [settingsStoryboard instantiateViewControllerWithIdentifier:constControllerManifestID];
    
    manifestController.title = NSLocalizedString(@"Update", @"Update");
    manifestController.tabBarItem.image = [UIImage imageNamed:@"Update"];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:settingsViewConroller, manifestController, nil];
    
    window.rootViewController = tabBarController;
    
    [window makeKeyAndVisible];
    
    // Update
    [[HelperManager sharedManager] setTimerUpdateHardware];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[HelperManager sharedManager] invalidateTimers];
    [[HelperManager sharedManager] setTimerUpdateHardware];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[HelperManager sharedManager] invalidateTimers];
    [[HelperManager sharedManager] setTimerUpdateHardware];
}


@end
