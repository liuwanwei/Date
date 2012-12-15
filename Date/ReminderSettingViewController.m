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
#import "ReminderSettingAudioCell.h"

@interface ReminderSettingViewController () {
    Reminder * _reminder;
    NSArray * _tags;
    NSArray * _days;
    NSMutableArray * _hours;
    NSMutableArray * _minutes;
    BOOL _setTime;
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
    _tags = [[NSArray alloc] initWithObjects:@"记得做", @"记得带", @"记得买",@"记一下", nil];
    
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
    
    SoundManager * manager = [SoundManager defaultSoundManager];
    _reminder.audioUrl = [manager.recordFileURL relativePath];
    _reminder.audioLength = [NSNumber numberWithInteger:manager.currentRecordTime];

    _setTime = YES;
}

- (void)initPickerView {
    NSDate * now = [NSDate date];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerView setHidden:NO];
    
    [_pickerView selectRow:1 inComponent:0 animated:NO];
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
    self.tableView.rowHeight = 44.0; 
    _reminder = [[ReminderManager defaultManager] reminder];
    [self initData];
    [self initPickerView];
    [self setReminderDate];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(chooseFriends)];
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
        SoundManager * manager = [SoundManager defaultSoundManager];
        _reminder.audioUrl = [manager.recordFileURL relativePath];
        _reminder.audioLength = [NSNumber numberWithInteger:manager.currentRecordTime];
    }
}

- (IBAction)playRecord:(id)sender {
    SoundManager * manager = [SoundManager defaultSoundManager];
    [manager playRecording];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

#define IsZero(float) (float > - 0.000001 && float < 0.000001)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier;
    UITableViewCell * cell;
    ReminderSettingAudioCell * audioCell;

    if (0 == indexPath.row) {
        CellIdentifier = @"ReminderSettingAudioCell";
        audioCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (audioCell == nil) {
            audioCell = [[ReminderSettingAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            audioCell.delegate = self;
        }
        audioCell.labelTitle.text = @"内容";
        audioCell.reminder = _reminder;
        audioCell.indexPath = indexPath;
        audioCell.audioState = AudioStateNormal;
        cell = audioCell;
        
    }else {
        CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"标签";
            if (nil == _reminder.desc) {
                _reminder.desc = [_tags objectAtIndex:0];
            }
            cell.detailTextLabel.text =  _reminder.desc;
        }else if (indexPath.row == 2) {
            ReminderSettingTimeCell * timeCell;
            CellIdentifier = @"ReminderSettingTimeCell";
            timeCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (timeCell == nil) {
                timeCell = [[ReminderSettingTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                timeCell.delegate = self;
            }
            timeCell.labelTitle.text = @"时间";
            cell = timeCell;
            
        }else if (indexPath.row == 3){
            cell.textLabel.text = @"地点";
            if (_reminder.longitude.length == 0 || _reminder.latitude.length == 0) {
                cell.detailTextLabel.text = @"未设置";
            }else{
                cell.detailTextLabel.text = @"已设置";
            }
        }
    }
    
    return cell;
}

#pragma mark - ChoiceViewDelegate
-(void)choiceViewController:(ChoiceViewController *)choiceViewController gotChoice:(NSArray *)choices{
//    choiceViewController.currentChoices = choices;
    _reminder.desc = [choices objectAtIndex:0];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
//        [_pickerView setHidden:!_pickerView.hidden];
        ChoiceViewController * choiceViewController = [[ChoiceViewController alloc] initWithStyle:UITableViewStyleGrouped];
        choiceViewController.choices = _tags;
        if (_reminder.desc != nil) {
            choiceViewController.currentChoices = [NSArray arrayWithObject:_reminder.desc];
        }
        choiceViewController.delegate = self;
        choiceViewController.type = SingleChoice;
        choiceViewController.autoDisappear = YES;
    
        [self.navigationController pushViewController:choiceViewController animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
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
//    NSIndexPath * tableRow =  [NSIndexPath indexPathForRow:0 inSection:0];
//    UITableViewCell * cell = [_tableView cellForRowAtIndexPath:tableRow];
//    
//    [cell.detailTextLabel setText:[self tiggerDate]];
    [self setReminderDate];
}

#pragma mark - ReminderSettingTimeCell Delegate
- (void)valueChangedWithSwitch:(UISwitch *)sender {
     [_pickerView setHidden:!_pickerView.hidden];
    _setTime = !_setTime;
    if (YES == _setTime) {
        [self setReminderDate];
    }else {
        _reminder.triggerTime = nil;
    }
}
@end
