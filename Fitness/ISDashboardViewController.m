//
//  ISDashboardViewController.m
//  Fitness
//
//  Created by ispluser on 2/11/14.
//  Copyright (c) 2014 ISC. All rights reserved.
//

#import "ISDashboardViewController.h"
#import "ISAppDelegate.h"
#import "macros.h"
#import "MMDrawerBarButtonItem.h"
#import "ISPathViewController.h"
#import "ISProfileViewController.h"
#import "ILAlertView.h"




@interface ISDashboardViewController ()

@end

@implementation ISDashboardViewController
{
    ISAppDelegate *appDel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDel=(ISAppDelegate*)[[UIApplication sharedApplication]delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupMenuItemsTouchEvents];
   
//    [appDel.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//    [appDel.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [[appDel getHRDistributor] setDashBoardDelegate:self];
    if (![[appDel woHandler] isUserProfileSet]) {
        ISProfileViewController *userProfile=[[ISProfileViewController alloc]initWithNibName:nil bundle:nil];
        userProfile.wantsFullScreenLayout = YES;
        
        [self presentViewController:userProfile animated:YES completion:nil];
    }
       
}
-(void)viewWillAppear:(BOOL)animated
{
    
   
    if (![[appDel woHandler] isUserProfileSet]) {
        ISProfileViewController *userProfile=[[ISProfileViewController alloc]initWithNibName:nil bundle:nil];
        userProfile.wantsFullScreenLayout = YES;
         [(UINavigationController*)[(ISAppDelegate *)[[UIApplication sharedApplication]delegate] drawerController] presentViewController:userProfile animated:YES completion:nil];
    }
}


//--------------------------------setting up navigation bar--------------------------------------

-(void)setupNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    self.wantsFullScreenLayout=YES;
    self.navigationController.navigationBar.translucent=NO;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:254.0/255.0 green:247.0/255.0 blue:235.0/255.0 alpha:1.0]];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:254.0/255.0 green:247.0/255.0 blue:235.0/255.0 alpha:1.0]];
        
    }
    
   
    
    UIView *backView =[[UIView alloc] initWithFrame:CGRectMake(0, 20, 200, 80)];
    [backView setBackgroundColor:[UIColor greenColor]];
    
    UILabel *titleLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 27)];
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.text=@"Dashboard";
    titleLable.font=[UIFont fontWithName:@"Arial" size:20.0];
    titleLable.textColor= [UIColor colorWithHue:31.0/360.0 saturation:99.0/100.0 brightness:87.0/100.0 alpha:1];
    
    
    [backView addSubview:titleLable];
    self.navigationItem.titleView=titleLable;
    self.navigationItem.titleView.backgroundColor=[UIColor clearColor];
    //self.navigationController.navigationBarHidden=YES;
    self.title=@"Dashboard";
    UIImage *backImage=[UIImage imageNamed:@"back.png"];
    [self.navigationItem.backBarButtonItem setImage:backImage];
    [self setupLeftMenuButton];
    
}
-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:NO];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [leftDrawerButton setTintColor: [UIColor colorWithHue:31.0/360.0 saturation:99.0/100.0 brightness:87.0/100.0 alpha:1]];
    }
    
}
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

//----------------------------handling touch events on items---------------
-(void)setupMenuItemsTouchEvents
{
    UITapGestureRecognizer *tapOnMapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(displayPathOnMap:)] ;
    tapOnMapView.numberOfTapsRequired=1;
    [self.mapPathView addGestureRecognizer:tapOnMapView];
    
    UITapGestureRecognizer *tapOnReportView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(displayReport:)] ;
    tapOnReportView.numberOfTapsRequired=1;
    [self.reportView addGestureRecognizer:tapOnReportView];
    
    
    
}
-(void) displayPathOnMap:(id)sender
{

    [(UINavigationController*)[appDel drawerController].centerViewController pushViewController:[[ISPathViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
}
-(void) displayReport:(id)sender
{
    [(UINavigationController*)[appDel drawerController].centerViewController pushViewController:[appDel getReportsViewController] animated:YES];
}

//---------------------------------handling heart value change-------------------------
-(void)didUpdateCurrentHeartRate:(NSNumber *)currHr maxHeartRate:(NSNumber *)maxHr minHeartRate:(NSNumber *)minHr
{
    self.hrLabel.text=[NSString stringWithFormat:@"%@ bpm",[currHr stringValue] ];
    self.maxHRLabel.text=[NSString stringWithFormat:@"Max - %@ bpm",[maxHr stringValue] ];
    self.minHRLabel.text=[NSString stringWithFormat:@"Min - %@ bpm",[minHr stringValue] ];
    
    
    self.calBurnedLabel.text= [NSString stringWithFormat:@"%.2f kcal" ,[appDel.woHandler.currentWO.calBurned doubleValue]/1000];
    [self calculateGoalCompletion];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)calculateWODuration
{
    
    if (!appDel.woHandler.isWOStarted) {
        return;
    }
    
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSMinuteCalendarUnit
                                       fromDate:appDel.woHandler.currentWO.startTimeStamp
                                       toDate:[NSDate date]
                                       options:0];
    
    self.woDurationLabel.text=[NSString stringWithFormat:@"%d Min",ageComponents.minute];
    [self calculateGoalCompletion];
    if (appDel.woHandler.isWOStarted) {
    
        [self performSelector:@selector(calculateWODuration) withObject:nil afterDelay:60.0];
    }
}
-(void)calculateGoalCompletion
{
    if (!appDel.woHandler.isWOStarted) {
        return;
    }
    
    if (appDel.woHandler.isWOGoalEnable) {
        
        double completed=0.0;
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                           components:NSMinuteCalendarUnit
                                           fromDate:appDel.woHandler.currentWO.startTimeStamp
                                           toDate:[NSDate date]
                                           options:0];
        
        switch (appDel.woHandler.woGoal.goalType) {
            case MILES:
                
                break;
                
            case CALORIES:
                
                completed=([appDel.woHandler.currentWO.calBurned doubleValue]/1000)/[appDel.woHandler.woGoal.goalValue doubleValue]*100.0;
                break;
                
            case DURATION:
                
                completed=(double)ageComponents.minute /[appDel.woHandler.woGoal.goalValue doubleValue]*100.0;
                break;
                
        }
        
        
        if (completed>100.0) {
            completed=100.0;
        }
        
        self.goalLabel.text=[NSString stringWithFormat:@"%.0f %%",completed];
       
        if (completed>=100) {
            
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateBackground || state==UIApplicationStateInactive)
            {
                
                UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
                localNotification.alertBody = @"Workout Goal Completed";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                localNotification.alertAction = @"View Details";
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.applicationIconBadgeNumber = 1;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
            else if(state==UIApplicationStateActive)
            {
                [ILAlertView showWithTitle:[NSString stringWithFormat:@"Success"]
                                   message:@"Workout Goal Completed"
                          closeButtonTitle:@"OK"
                         secondButtonTitle:nil
                        tappedSecondButton:nil];
            }
            
            [self.startWOButton setTitle:@"Start Workout" forState:UIControlStateNormal];
            [appDel.woHandler stopWO];
        }
        
        
        
    }
    else
    {
        self.goalLabel.text=@"- -";
    }
}

- (IBAction)workoutStart:(id)sender {
    
    if ([self.startWOButton.titleLabel.text isEqualToString:@"Start Workout"]) {
        
        [self.startWOButton setTitle:@"Stop Workout" forState:UIControlStateNormal];
        [appDel.woHandler startWO];
        [self calculateWODuration];
        [self calculateGoalCompletion];
        
    }
    else
    {
        [self.startWOButton setTitle:@"Start Workout" forState:UIControlStateNormal];
        [appDel.woHandler stopWO];
    }
    
    
}

























@end
