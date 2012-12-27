//
//  ReminderTimeSettingViewController.m
//  date
//
//  Created by maoyu on 12-12-26.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderTimeSettingViewController.h"

@interface ReminderTimeSettingViewController () {
    NSArray * _days;
    NSMutableArray * _hours;
    NSMutableArray * _minutes;
}

@end

@implementation ReminderTimeSettingViewController
@synthesize tableView = _tableView;
@synthesize pickerView = _pickerView;
@synthesize parentContoller = _parentContoller;

#pragma 私有函数
- (void)initData {
    _days = [[NSArray alloc] initWithObjects:@"今天",@"明天",@"后天", nil];
    
    _minutes = [[NSMutableArray alloc] init];
    int step = 5;
    for(int i = 0; i < 60 ; i ++){
        if (i % step == 0) {
            [_minutes addObject:[NSString stringWithFormat:@"%02d", i]];
        }
    }
    
    _hours = [[NSMutableArray alloc] init];
    for (int i = 0; i < 24; i ++) {
        [_hours addObject:[NSString stringWithFormat:@"%02d", i]];
    }
}

- (void)initPickerView {
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    NSDateFormatter * hour = [[NSDateFormatter alloc] init];
    NSString * currentDateStr;
    NSInteger hourIndex;
    [hour setDateFormat:@"HH"];
    if (nil == _parentContoller.triggerTime) {
        NSDate * now = [NSDate date];
        [_pickerView selectRow:0 inComponent:0 animated:NO];
        currentDateStr = [hour stringFromDate:now];
        hourIndex = [currentDateStr integerValue];
        [_pickerView selectRow:hourIndex inComponent:1 animated:NO];
        [_pickerView selectRow:6 inComponent:2 animated:NO];
    }else {
        NSString * day = [_parentContoller custumDayString:_parentContoller.triggerTime];
        NSInteger dayIndex = 0;
        for (NSString * tmpDay in _days) {
            if ([tmpDay isEqualToString:day]) {
                [_pickerView selectRow:dayIndex inComponent:0 animated:NO];
                break;
            }
            dayIndex ++;
        }
        
        currentDateStr = [hour stringFromDate:_parentContoller.triggerTime];
        hourIndex = [currentDateStr integerValue];
        [_pickerView selectRow:hourIndex inComponent:1 animated:NO];
        
        [hour setDateFormat:@"mm"];
        NSInteger minute;
        currentDateStr = [hour stringFromDate:_parentContoller.triggerTime];
        minute = [currentDateStr integerValue];
        [_pickerView selectRow:minute/5 inComponent:2 animated:NO];
    }
}

- (void)tiggerTime {
    NSDate * now = [NSDate date];
    NSDateFormatter * hour = [[NSDateFormatter alloc] init];
    [hour setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString * strTriggerDate = [hour stringFromDate:now];
    NSDate * triggerDate = [hour dateFromString:strTriggerDate];
    triggerDate = [triggerDate dateByAddingTimeInterval:24*60*60*[_pickerView selectedRowInComponent:0]];
    triggerDate = [triggerDate dateByAddingTimeInterval:[_pickerView selectedRowInComponent:1]*60*60];
    triggerDate = [triggerDate dateByAddingTimeInterval:[_pickerView selectedRowInComponent:2]*5*60];
    _parentContoller.triggerTime = triggerDate;
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
    [self initData];
    [self initPickerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_parentContoller updateTriggerTimeCell];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = @"提醒时间";
    if (nil != _parentContoller.triggerTime) {
        cell.detailTextLabel.text = [_parentContoller custumDateTimeString:_parentContoller.triggerTime];
    }
    
    return cell;
}

#pragma  mark - PickerView data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _days.count;
    }else if(component == 1){
        return _hours.count;
    }else {
        return _minutes.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component == 0){
        return [_days objectAtIndex:row];
    }else if(component == 1) {
        return [_hours objectAtIndex:row];
    }else {
        return [_minutes objectAtIndex:row];
    }
}

#pragma  mark - PickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self tiggerTime];
    [self.tableView reloadData];
}

@end
