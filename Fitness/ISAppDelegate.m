//
//  ISAppDelegate.m
//  Fitness
//
//  Created by ispluser on 2/6/14.
//  Copyright (c) 2014 ISC. All rights reserved.
//

#import "ISAppDelegate.h"
#import "ISProfileViewController.h"
#import "ISMenuViewController.h"
#import "ISDashboardViewController.h"
#import "MMExampleDrawerVisualStateManager.h"


@implementation ISAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ISDashboardViewController *dashboardVC = [[ISDashboardViewController alloc]initWithNibName:nil bundle:nil];
    ISMenuViewController *menuVC = [[ISMenuViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *dashboardNVC = [[UINavigationController alloc]initWithRootViewController:dashboardVC];
   
    
    
    self.drawerController= [[MMDrawerController alloc]initWithCenterViewController:dashboardNVC leftDrawerViewController:menuVC];
    
    
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    // [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeSwingingDoor];
    
    [self.drawerController setShowsShadow:NO];
    [self.drawerController setMaximumLeftDrawerWidth:275.0];
    [self getBluetoothManager];
    self.dbManager=[ISDBManager getSharedInstance];
    self.woHandler=[ISWorkOutHandler getSharedInstance];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (![self.woHandler isUserProfileSet]) {
        ISProfileViewController *userProfile=[[ISProfileViewController alloc]initWithNibName:nil bundle:nil];
        userProfile.wantsFullScreenLayout = YES;
        [self.window setRootViewController:userProfile];
    }
    else
    {
        [self.window setRootViewController:self.drawerController];
    }
    
    return YES;
}

-(ISHRDistributor *)getHRDistributor
{
    if (self.hrDistributor==nil) {
        self.hrDistributor=[[ISHRDistributor alloc]init];
        //setting intial hr values to avoid wrong interpretations
        self.hrDistributor.maxHR=@0;
        self.hrDistributor.minHR=@1000;
    }
    
    return self.hrDistributor;
}


-(ISBluetooth *)getBluetoothManager
{
    if (self.bluetoothManager==nil) {
        self.bluetoothManager=[[ISBluetooth alloc]init];
        self.bluetoothManager.notificationDelegate=[self getHRDistributor];
    }
    
    return self.bluetoothManager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
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
