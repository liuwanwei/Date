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
    NSIndexPath * _curIndexPath;
    UILabel * _labelPrompt;
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
    switch (_curIndexPath.row) {
        case 2:
            _parentContoller.triggerTime = nil;
            _parentContoller.reminderType = ReminderTypeReceiveAndNoAlarm;
            break;
        case 0:
            _parentContoller.reminderType = ReminderTypeReceiveAndNoAlarm;
            _parentContoller.triggerTime = _datePick.date;
            break;
        case 1:
            _parentContoller.reminderType = ReminderTypeReceive;
            _parentContoller.triggerTime = _datePick.date;
            break;
        default:
            break;
    }
    [_parentContoller updateTriggerTimeCell];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)restoreView {
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

- (void)initTableFooterView {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 150)];
    _labelPrompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
    _labelPrompt.backgroundColor = [UIColor clearColor];
    _labelPrompt.textAlignment = NSTextAlignmentCenter;
    _labelPrompt.textColor = RGBColor(153,153,153);
    _labelPrompt.text = @"将加入收集箱中，暂不提醒";
    [_labelPrompt setHidden:YES];
    [view addSubview:_labelPrompt];
    self.tableView.tableFooterView = view;
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
    [self initTableFooterView];
    [self initPickerView];
    _curIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self showPickerViewWithMode:UIDatePickerModeDate];
    _rows = [[NSArray alloc] initWithObjects:kOneDayTimeDesc,kAlarmTimeDesc,kInboxTimeDesc, nil];
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
    }
    if (_curIndexPath.row == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:_curIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    _curIndexPath = indexPath;
    cell = [tableView cellForRowAtIndexPath:_curIndexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    switch (indexPath.row) {
        case 0:
            [_labelPrompt setHidden:YES];
            [self showPickerViewWithMode:UIDatePickerModeDate];
            break;
        case 1:
            [_labelPrompt setHidden:YES];
            [self showPickerViewWithMode:UIDatePickerModeDateAndTime];
            break;
        case 2:
            [_labelPrompt setHidden:NO];
            [self restoreView];
            break;
        default:
            break;
    }
    
}

@end
