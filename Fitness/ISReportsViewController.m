//
//  ISReportsViewController.m
//  Fitness
//
//  Created by ispluser on 2/18/14.
//  Copyright (c) 2014 ISC. All rights reserved.
//

#import "ISReportsViewController.h"
#import "macros.h"
#import "ISReportDetailCell.h"
#import "ISReportDetailsViewController.h"
#import "ISWorkOut.h"
#import "ISAppDelegate.h"

@interface ISReportsViewController ()

@end

@implementation ISReportsViewController
{
    
    ISAppDelegate *appDel;
    NSMutableArray*  workouts;
    ISReportDetailsViewController *reportDetailsVC;
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        appDel=(ISAppDelegate*)[[UIApplication sharedApplication]delegate];
        reportDetailsVC=[[ISReportDetailsViewController alloc]initWithNibName:nil bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBar];
    self.tableView.separatorColor=[UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    
    self.tableView.backgroundView = imageView;
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    workouts=[NSMutableArray arrayWithArray:[ISWorkOut getWorkouts]];
    
    if (appDel.woHandler.isWOStarted) {
        
        
        for (ISWorkOut *w in workouts) {
            if (w.woId==appDel.woHandler.currentWO.woId) {
                [workouts removeObject:w];
                break;
            }
        }
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------setting up navigation bar--------------------------------------

-(void)setupNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    self.wantsFullScreenLayout=YES;
    
    
    self.navigationController.navigationBar.translucent=NO;
    
    UILabel *titleLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
    
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.text=@"Workout Reports";
    titleLable.font=[UIFont fontWithName:@"Arial" size:20.0];
    titleLable.textColor= [UIColor colorWithHue:31.0/360.0 saturation:99.0/100.0 brightness:87.0/100.0 alpha:1];
    
    self.navigationItem.titleView=titleLable;
    self.navigationItem.titleView.backgroundColor=[UIColor clearColor];
    float xSpace=SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?-10.0f:-0.0f;
    
    
    UIView *backView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [backView setBackgroundColor:[UIColor clearColor]];
    UITapGestureRecognizer *tapBack=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goBack:)];
    tapBack.numberOfTapsRequired=1;
    [backView addGestureRecognizer:tapBack];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setFrame:CGRectMake(xSpace, 3.0f, 25.0f, 25.0f)];
    [backButtonCustom addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButtonCustom setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backView addSubview:backButtonCustom];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backView];
    
    // [backButton setTintColor: [UIColor colorWithHue:31.0/360.0 saturation:99.0/100.0 brightness:87.0/100.0 alpha:1]];
    [self.navigationItem setLeftBarButtonItem:backButton];
   
    
    
}
-(void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}





//--------------------------------handling table view controller-------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [workouts count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportCell";
    ISReportDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[ISReportDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ];
        
        
        
    }
    ISWorkOut *wo=(ISWorkOut*)[workouts objectAtIndex:indexPath.row];
    int goalId=wo.woGoalId;
    NSString *goalTypeLabel=@"Calories :";
    NSString *goalValueLabel=[NSString stringWithFormat:@"%@  kcal",wo.calBurned];
    if (goalId!=0)
    {
        ISWOGoal *goal=[ISWOGoal getWOGoalWithId:goalId];
        
        switch (goal.goalType) {
            case MILES:
                goalTypeLabel=@"Miles :";
                goalValueLabel=[NSString stringWithFormat:@"%.1f  miles",[wo.distance doubleValue]];
                break;
            case CALORIES:
                goalTypeLabel=@"Calories :";
                goalValueLabel=[NSString stringWithFormat:@"%.2f  kcal",[wo.calBurned doubleValue]/1000];
                break;
            case DURATION:
                goalTypeLabel=@"Duration :";
                NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                                   components:NSMinuteCalendarUnit
                                                   fromDate:wo.startTimeStamp
                                                   toDate:wo.endTimeStamp
                                                   options:0];
                
                goalValueLabel=[NSString stringWithFormat:@"%d min",ageComponents.minute];
                break;
        }
        
    }
    
    [cell setGoalTypeLabel:goalTypeLabel workoutDateLabel:wo.startTimeStamp goalValueLabel:goalValueLabel];
    
    
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    reportDetailsVC.workout=[workouts objectAtIndex:indexPath.row];
    [(UINavigationController*)[appDel drawerController].centerViewController pushViewController:reportDetailsVC animated:YES];
}


@end
