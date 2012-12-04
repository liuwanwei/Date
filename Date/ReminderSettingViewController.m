//
//  ReminderSettingViewController.m
//  Date
//
//  Created by maoyu on 12-11-19.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderSettingViewController.h"
#import "SoundManager.h"
#import "Reminder.h"
#import "ReminderManager.h"
#import "ReminderMapViewController.h"
#import "ReminderSendingViewController.h"

@interface ReminderSettingViewController () {
    Reminder * _reminder;
    NSArray * _days;
    NSArray * _hours;
    NSMutableArray * _minutes;
}

@end

@implementation ReminderSettingViewController
@synthesize tableView = _tableView;
@synthesize pickerView = _pickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initData {
    _days = [[NSArray alloc] initWithObjects:@"今天",@"明天",@"后天", nil];
    _hours = [[NSArray alloc] initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23", nil];
    
    _minutes = [[NSMutableArray alloc] initWithCapacity:0];
    NSInteger size = 12;
    for (NSInteger index = 0; index < size; index++) {
        [_minutes addObject:[NSString stringWithFormat:@"%.2d",index * 5]];
    }
    
    SoundManager * manager = [SoundManager defaultSoundManager];
    _reminder.audioUrl = [manager.recordFileURL relativePath];
}

- (void)initPickerView {
    NSDate * now = [NSDate date];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerView setHidden:YES];
    NSDateFormatter * hour = [[NSDateFormatter alloc] init];
    [hour setDateFormat:@"HH"];
    NSString * currentDateStr = [hour stringFromDate:now];
    NSInteger hourIndex = [currentDateStr integerValue];
    [_pickerView selectRow:hourIndex inComponent:1 animated:NO];
    [hour setDateFormat:@"mm"];
    currentDateStr = [hour stringFromDate:now];
    [_pickerView selectRow:6 inComponent:2 animated:NO];
}

- (void)setReminderDate {
    NSDate * now = [NSDate date];
    NSDateFormatter * hour = [[NSDateFormatter alloc] init];
    [hour setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString * strTriggerDate = [hour stringFromDate:now];
    NSDate * triggerDate = [hour dateFromString:strTriggerDate];
    triggerDate = [triggerDate dateByAddingTimeInterval:24*60*60*[_pickerView selectedRowInComponent:0]];
    triggerDate = [triggerDate dateByAddingTimeInterval:[_pickerView selectedRowInComponent:1]*60*60];
    triggerDate = [triggerDate dateByAddingTimeInterval:[_pickerView selectedRowInComponent:2]*5*60];
    _reminder.triggerTime = triggerDate;
}

- (void)chooseFriends {
    ReminderSendingViewController * controller = [[ReminderSendingViewController alloc] initWithNibName:@"ReminderSendingViewController" bundle:nil];
    controller.reminder = _reminder;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSString *)tiggerDate {
    NSString * date;
    date = [_days objectAtIndex:[_pickerView selectedRowInComponent:0]];
    date = [date stringByAppendingString:@"  "];
    date = [date stringByAppendingString:[_hours objectAtIndex:[_pickerView selectedRowInComponent:1]]];
    date = [date stringByAppendingString:@"点"];
    date = [date stringByAppendingString:@"  "];
    date = [date stringByAppendingString:[_minutes objectAtIndex:[_pickerView selectedRowInComponent:2]]];
    date = [date stringByAppendingString:@"分"];
    return date;
}

#pragma 事件函数
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"约定";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _reminder = [[ReminderManager defaultManager] reminder];
    [self initData];
    [self initPickerView];
    [self setReminderDate];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(chooseFriends)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRecord:(id)sender {
    SoundManager * manager = [SoundManager defaultSoundManager];
    manager.view.frame = CGRectMake(50.0, 100.0, manager.view.frame.size.width, manager.view.frame.size.height);
    [self.view addSubview:manager.view];
    [manager startRecord];
}

- (IBAction)stopRecord:(id)sender {
    SoundManager * manager = [SoundManager defaultSoundManager];
    [manager.view removeFromSuperview];
    if (YES == [manager stopRecord]) {
        
    }
}

- (IBAction)playRecord:(id)sender {
    SoundManager * manager = [SoundManager defaultSoundManager];
    [manager playRecording];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"时间";
        if (nil != _reminder.triggerTime) {
            cell.detailTextLabel.text = [self tiggerDate];
        }
    
    }else {
        cell.textLabel.text = @"地点";
        if (nil != _reminder.adress) {
            cell.detailTextLabel.text = _reminder.adress;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [_pickerView setHidden:!_pickerView.hidden];
    }
    if (indexPath.section == 1) {
        ReminderMapViewController * controller = [[ReminderMapViewController alloc] initWithNibName:@"ReminderMapViewController" bundle:nil];
        controller.reminder = _reminder;
        controller.type = MapOperateTypeSet;
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:nil];
    }
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
    NSIndexPath * tableRow =  [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell * cell = [_tableView cellForRowAtIndexPath:tableRow];
    
    [cell.detailTextLabel setText:[self tiggerDate]];
    [self setReminderDate];
}
@end
