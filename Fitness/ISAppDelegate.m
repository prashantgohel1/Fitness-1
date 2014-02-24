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
#import "ISConnectionManagerViewController.h"
#import "ILAlertView.h"


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

//------------------------initializing VC-------------------------------


-(ISSetWorkoutGoalViewController*)getSetWorkoutGoalViewController
{
    if (self.setWorkoutGoalViewController==nil) {
        self.setWorkoutGoalViewController=[[ISSetWorkoutGoalViewController alloc]initWithNibName:nil bundle:nil];
    }
    
    return self.setWorkoutGoalViewController;
}
-(ISHRMonitorViewController*)getHRMonitorViewController
{
    if (self.hrMonitorViewController==nil) {
        self.hrMonitorViewController=[[ISHRMonitorViewController alloc]initWithNibName:nil bundle:nil];
    }
    
    return self.hrMonitorViewController;
}
-(ISConnectionManagerViewController*)getConnectionManagerViewController
{
    if (self.connectionManagerViewController==nil) {
        self.connectionManagerViewController=[[ISConnectionManagerViewController alloc]initWithNibName:nil bundle:nil];
    }
    
    return self.connectionManagerViewController;
}
-(ISProfileViewController*)getProfileViewController
{
    if (self.profileViewController==nil) {
        self.profileViewController=[[ISProfileViewController alloc]initWithNibName:nil bundle:nil];
        self.profileViewController.wantsFullScreenLayout=YES;
    }
    
    return self.profileViewController;
}

-(ISHRDistributor *)getHRDistributor
{
    if (self.hrDistributor==nil) {
        self.hrDistributor=[[ISHRDistributor alloc]init];
        //setting intial hr values to avoid wrong interpretations
        [self.hrDistributor reset];
    }
    
    return self.hrDistributor;
}


-(ISBluetooth *)getBluetoothManager
{
    if (self.bluetoothManager==nil) {
        self.bluetoothManager=[[ISBluetooth alloc]init];
        self.bluetoothManager.connectionDelegate=self;
        self.bluetoothManager.notificationDelegate=[self getHRDistributor];
    }
    
    return self.bluetoothManager;
}
-(void)peripheralDidConnect
{
    self.woHandler.isDeviceConnected=YES;
}
-(void)peripheralDidDisconnect:(NSError *)error
{
    [self.hrDistributor saveData];
    self.woHandler.isDeviceConnected=NO;
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state==UIApplicationStateInactive)
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.alertBody = @"Device Disconnected";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertAction = @"View Details";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    else if(state==UIApplicationStateActive)
    {
        [ILAlertView showWithTitle:[NSString stringWithFormat:@"Device Disconnected"]
                           message:@"Connect Another Device?"
                  closeButtonTitle:@"NO"
                 secondButtonTitle:@"Yes"
                tappedSecondButton:^{
                    [(UINavigationController*)self.drawerController.centerViewController popToRootViewControllerAnimated:NO];
                    [(UINavigationController*)[self drawerController].centerViewController pushViewController:[[ISConnectionManagerViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
                }];
    }

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
     application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
