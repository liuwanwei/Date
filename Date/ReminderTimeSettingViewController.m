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
    float _viewHeight;
    NSArray * _cellIcons;
    BOOL _dirty;
    BOOL _showed;
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
    [_datePick setFrame:CGRectMake(0,_viewHeight , 320, 216)];
    _datePick.minimumDate = [NSDate date];
    [_datePick setDate:[NSDate date]];
    [self.view addSubview:_datePick];
    [_datePick addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)updateTime{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * strTriggerTime;
    switch (_selectedRow) {
        case 2:
            _parentContoller.triggerTime = nil;
            _parentContoller.reminderType = ReminderTypeReceiveAndNoAlarm;
            break;
        case 0:
            [formatter setDateFormat:@"yyyy-MM-dd 23:59:59"];
            strTriggerTime = [formatter stringFromDate:_datePick.date];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            _parentContoller.reminderType = ReminderTypeReceiveAndNoAlarm;
            _parentContoller.triggerTime = [formatter dateFromString:strTriggerTime];
            break;
        case 1:
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
            strTriggerTime = [formatter stringFromDate:_datePick.date];
            _parentContoller.reminderType = ReminderTypeReceive;
            _parentContoller.triggerTime = [formatter dateFromString:strTriggerTime];
            break;
        default:
            break;
    }
    [_parentContoller updateTriggerTimeCell];
}

- (void)back {
    if (YES == _dirty) {
        [self updateTime];
    }
    
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
            [self hideDatePickerView];
            break;
        default:
            break;
    }
}

- (void)hideDatePickerView {
    if (_showed) {
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        
        // set views with new info
        _datePick.frame = CGRectMake(0,_viewHeight - 64 , 320, 216);
        // commit animations
        [UIView commitAnimations];
        
        _showed = NO;
    }
}

- (void)showPickerViewWithMode:(UIDatePickerMode)pickMode {
    if (_showed && _datePick.datePickerMode == pickMode) {
        return;
    }
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    dispatch_async(queue, ^{[_datePick setDatePickerMode:pickMode];});
    [_datePick setDatePickerMode:pickMode];
    
    
    if (pickMode == UIDatePickerModeDateAndTime) {
        _datePick.minuteInterval = 5;
    }
 
    if (! _showed) {
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        
        // set views with new info
        _datePick.frame = CGRectMake(0,_viewHeight - 216 - 64 , 320, 216);
        // commit animations
        [UIView commitAnimations];
        
        _showed = YES;
    }
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

- (void)valueChanged:(UIDatePicker *)datePicker {
    _dirty = YES;
}

- (void)done{
    [self updateTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReminderSettingOk object:nil];
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _cellIcons = [NSArray arrayWithObjects:@"reminderSettingCalendar", @"reminderSettingAlarm", @"CollectingBox", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSelectedReminderTypeIndex];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    _viewHeight = window.frame.size.height;
    [self initTableFooterView];
    _rows = [[NSArray alloc] initWithObjects:kOneDayTimeDesc,kAlarmTimeDesc,kInboxTimeDesc, nil];
    [[GlobalFunction defaultInstance] initNavleftBarItemWithController:self withAction:@selector(back)];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [[GlobalFunction defaultInstance] customNavigationBarItem:item];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initPickerView];
    [self reloadDatePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_datePick removeTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
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
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[_cellIcons objectAtIndex:indexPath.row]];
        
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _dirty = YES;
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedRow != -1 && self.selectedRow != indexPath.row) {
        NSIndexPath * lastSelectedIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
        lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.selectedRow = indexPath.row;
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self reloadDatePicker];
}

@end
