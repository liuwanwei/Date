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
#import "SinaWeiboManager.h"

@interface ReminderSettingViewController () {
    NSArray * _tags;
    BOOL _sending;
    NSDate * _triggerTime;
    BOOL _isSpread;
    BOOL _isLogin;
    BOOL _isAuthValid;
}

@end

@implementation ReminderSettingViewController
@synthesize tableView = _tableView;
@synthesize pickerView = _pickerView;
@synthesize settingMode = _settingMode;
@synthesize reminder = _reminder;

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
    
    if (SettingModeNew == _settingMode) {
        SoundManager * manager = [SoundManager defaultSoundManager];
        _reminder.audioUrl = [manager.recordFileURL relativePath];
        _reminder.audioLength = [NSNumber numberWithInteger:manager.currentRecordTime];
    }
    
    if (SettingModeNew == _settingMode) {
        
    }else {
        _triggerTime = _reminder.triggerTime;
    }

    _sending = YES;
}


- (void)chooseFriends {
    _reminder.triggerTime = _triggerTime;
    if (_sending) {
        /* sending 发送给特定对象 */
        ReminderSendingViewController * controller = [[ReminderSendingViewController alloc] initWithNibName:@"ReminderSendingViewController" bundle:nil];
        controller.reminder = _reminder;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        /* collecting 收集 */
        _reminder.userID = [NSNumber numberWithLongLong:[[[UserManager defaultManager] userID] longLongValue] ];
        [[ReminderManager defaultManager] sendReminder:_reminder];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)modifyReminder {
    if (SettingModeNew == _settingMode) {
        _reminder.userID = [NSNumber numberWithLongLong:[[[UserManager defaultManager] userID] longLongValue] ];
        _reminder.triggerTime = _triggerTime;
        [[ReminderManager defaultManager] sendReminder:_reminder];

    }else {
        [[ReminderManager defaultManager] modifyReminder:_reminder withTriggerTime:_triggerTime withDesc:_reminder.desc];
    }
  
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma 事件函数
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"约定";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44.0;
    if (SettingModeNew == _settingMode) {
        _reminder = [[ReminderManager defaultManager] reminder];
    }
    [self initData];
    
    UIBarButtonItem * rightItem;
    NSString * title;
    if (nil == _triggerTime) {
        title = @"收集";
    }else {
        title = @"保存";
    }
    rightItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(modifyReminder)];
   
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _isLogin = [[SinaWeiboManager defaultManager].sinaWeibo isLoggedIn];
    _isAuthValid = [[SinaWeiboManager defaultManager].sinaWeibo isAuthValid];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (SettingModeModify == _settingMode) {
        return 3;
    }else if (NO == _isLogin) {
        return 3;
    }
    
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
            if (SettingModeModify == _settingMode) {
                timeCell.triggerTime = _triggerTime;

            }
            cell = timeCell;
            
        }else if (indexPath.row == 3){
            cell.textLabel.text = @"发送给";
            if (NO == _isAuthValid) {
                cell.detailTextLabel.text = @"已过期";
            }
            /*cell.textLabel.text = @"地点";
            if (_reminder.longitude.length == 0 || _reminder.latitude.length == 0) {
                cell.detailTextLabel.text = @"未设置";
            }else{
                cell.detailTextLabel.text = @"已设置";
            }*/
        }
    }
    
    return cell;
}

#pragma mark - ChoiceViewDelegate
-(void)choiceViewController:(ChoiceViewController *)choiceViewController gotChoice:(NSArray *)choices{
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
    }else if (indexPath.row == 2) {
        _isSpread = !_isSpread;
        
      [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        ReminderSettingTimeCell * timeCell = (ReminderSettingTimeCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (_isSpread == NO) {
            [timeCell.pickerView setHidden:YES];
        }else {
            [timeCell.pickerView setHidden:NO];
        }
    }else if (indexPath.row == 3) {
        ReminderSendingViewController * controller = [[ReminderSendingViewController alloc] initWithNibName:@"ReminderSendingViewController" bundle:nil];
        _reminder.triggerTime =  _triggerTime;
        controller.reminder = _reminder;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        if (NO == _isSpread){
            return 44.0f;
        }else {
            return 275.0f;
        }
    }
    
    return 44.0f;
}

- (void)triggerTimeChanged:(NSDate *)triggerTime {
    _triggerTime = triggerTime;
    if (nil == _triggerTime) {
        self.navigationItem.rightBarButtonItem.title = @"收集";
    }else {
        self.navigationItem.rightBarButtonItem.title = @"保存";
    }
}

@end
