//
//  AppDelegate.m
//  PinTu
//
//  Created by YLRS on 6/18/15.
//  Copyright (c) 2015 YLRS. All rights reserved.
//

#import "AppDelegate.h"
@import InMobiSDK.IMSdk;
#define AppStore            @"https://itunes.apple.com/us/app/pintu-puzzle/id1153946930?l=zh&ls=1&mt=8"

//#define INMOBI_ACCOUNT_ID   @"4028cb8b2c3a0b45012c406824e800ba"

#define INMOBI_ACCOUNT_ID   @"5b42424a6fcc4e94adc0c1e75151ad95"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self registerIMSDK];
    
    [self registerUmeng];
    
    // Override point for customization after application launch.
    return YES;
}
-(void)registerIMSDK
{
    [IMSdk initWithAccountID:INMOBI_ACCOUNT_ID];
    
    [IMSdk setLogLevel:kIMSDKLogLevelDebug];
}

#pragma mark - 友盟统计
- (void) registerUmeng{
    
    UMConfigInstance.appKey = @"570b1912e0f55ad649000660";
    
    [MobClick startWithConfigure:UMConfigInstance];
    
    //    [MobClick startWithAppkey:kUMengAppKey reportPolicy:BATCH channelId:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
