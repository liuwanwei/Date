//
//  ReminderTimeSettingViewController.m
//  date
//
//  Created by maoyu on 12-12-26.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderTimeSettingViewController.h"
#import "LMLibrary.h"
#import "AppDelegate.h"
#import "GlobalFunction.h"

@interface ReminderTimeSettingViewController () {
    NSArray * _rows;
    UIControl * _overView;
}

@end

@implementation ReminderTimeSettingViewController
@synthesize parentContoller = _parentContoller;
@synthesize datePick = _datePick;
@synthesize tableView = _tableView;
@synthesize finshView = _finshView;

#pragma 私有函数
- (void)initPickerView {
    [_datePick setFrame:CGRectMake(0, 456, 320, 216)];
    [self.view addSubview:_datePick];
    _datePick.minimumDate = [NSDate date];
    _datePick.minuteInterval = 5;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)restoreView {
    [_overView removeFromSuperview];
    _overView = nil;
    float viewHeight = self.view.bounds.size.height;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    
    // set views with new info
    _finshView.frame = CGRectMake(0,viewHeight, 320, 50);
    _datePick.frame = CGRectMake(0,viewHeight , 320, 216);
    // commit animations
    [UIView commitAnimations];
}

- (void)showPickerViewWithMode:(UIDatePickerMode)pickMode {
    float viewHeight = self.view.bounds.size.height;
    [_datePick setDatePickerMode:pickMode];
    if (nil == _overView) {
        _overView = [[UIControl alloc] init];
        _overView.backgroundColor = [UIColor whiteColor];
        _overView.frame = CGRectMake(0, 0, 320,viewHeight - 266);
        [_overView addTarget:self action:@selector(restoreView) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_overView];
    }
    
    _overView.backgroundColor = [UIColor clearColor];
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    
    // set views with new info

    _finshView.frame = CGRectMake(0,viewHeight - 266, 320, 50);
    _datePick.frame = CGRectMake(0,viewHeight - 216 , 320, 216);
    // commit animations
    [UIView commitAnimations];
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self initPickerView];
    _rows = [[NSArray alloc] initWithObjects:kInboxTimeDesc,kTodayTimeDesc,kTomorrowDesc,kOneDayTimeDesc,kAlarmTimeDesc, nil];
    [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickOK:(id)sender {
    if (UIDatePickerModeDate == _datePick.datePickerMode) {
        _parentContoller.reminderType = ReminderTypeReceiveAndNoAlarm;
    }else {
        _parentContoller.reminderType = ReminderTypeReceive;
    }
    
    _parentContoller.triggerTime = _datePick.date;
    [_parentContoller updateTriggerTimeCell];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickCancel:(id)sender {
    [self restoreView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
    if (indexPath.row >= 3) {
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    BOOL back = NO;
    switch (indexPath.row) {
        case 0:
            back = YES;
            _parentContoller.triggerTime = nil;
            _parentContoller.reminderType = ReminderTypeReceiveAndNoAlarm;
            break;
        case 1:
            back = YES;
            _parentContoller.triggerTime = [NSDate date];
            _parentContoller.reminderType = ReminderTypeReceiveAndNoAlarm;
            break;
        case 2:
            back = YES;
            _parentContoller.triggerTime = [[GlobalFunction defaultGlobalFunction] tomorrow];
            _parentContoller.reminderType = ReminderTypeReceiveAndNoAlarm;
            break;
        case 3:
            [self showPickerViewWithMode:UIDatePickerModeDate];
            break;
        case 4:
            [self showPickerViewWithMode:UIDatePickerModeDateAndTime];
            break;
        default:
            break;
    }
    
    if (YES == back) {
        [_parentContoller updateTriggerTimeCell];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
