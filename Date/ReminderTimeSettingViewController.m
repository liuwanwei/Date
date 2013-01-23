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
    UILabel * _labelPrompt;
    
    NSArray * _cellIcons;
}

@end

@implementation ReminderTimeSettingViewController
@synthesize parentContoller = _parentContoller;
@synthesize datePick = _datePick;
@synthesize tableView = _tableView;
@synthesize finshView = _finshView;
@synthesize selectedRow = _selectedRow;

#pragma 私有函数
- (void)initPickerView {
    [_datePick setFrame:CGRectMake(0, 456, 320, 216)];
    [self.view addSubview:_datePick];
}

- (void)back {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    NSString * strTriggerTime = [formatter stringFromDate:_datePick.date];
    switch (_selectedRow) {
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
            _parentContoller.triggerTime = [formatter dateFromString:strTriggerTime];
            break;
        default:
            break;
    }
    [_parentContoller updateTriggerTimeCell];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initSelectedReminderTypeIndex{
    if (_parentContoller.reminderType == ReminderTypeReceiveAndNoAlarm) {
        if (_parentContoller.triggerTime == nil) {
            self.selectedRow = 2;
        }else{
            self.selectedRow = 0;
        }
    }else if(_parentContoller.reminderType == ReminderTypeReceive){
        self.selectedRow = 1;
    }else{
        // 默认选择
        self.selectedRow = 0;
    }
    
    [self reloadDatePicker];
}

- (void)reloadDatePicker{
    switch (self.selectedRow) {
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
    _datePick.minimumDate = [NSDate date];
    [_datePick setDate:[NSDate date]];
    [_datePick setDatePickerMode:pickMode];
        _datePick.minuteInterval = 5;
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
        _cellIcons = [NSArray arrayWithObjects:@"Calendar", @"Clock", @"CollectingBox", nil];
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

    [self showPickerViewWithMode:UIDatePickerModeDate];
    _rows = [[NSArray alloc] initWithObjects:kOneDayTimeDesc,kAlarmTimeDesc,kInboxTimeDesc, nil];
    [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
    
    [self initSelectedReminderTypeIndex];
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
    if (self.selectedRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[_cellIcons objectAtIndex:indexPath.row]];
        
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedRow != -1 && self.selectedRow != indexPath.row) {
        NSIndexPath * lastSelectedIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
        lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.selectedRow = indexPath.row;
    [self reloadDatePicker];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

@end
