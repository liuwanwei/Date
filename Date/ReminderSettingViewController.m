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
#import "MBProgressManager.h"
#import "AppDelegate.h"
#import "RemindersInboxViewController.h"

@interface ReminderSettingViewController () {
    NSArray * _tags;
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
@synthesize receiver = _receiver;

#pragma 私有函数
- (void)initTableFooterView {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 100)];
    UIButton * btnSave;
    btnSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnSave.layer.frame = CGRectMake(10, 15, 300, 44);
    [btnSave setBackgroundImage:[UIImage imageNamed:@"buttonBg"] forState:UIControlStateNormal];
    [btnSave setTitle:@"保存" forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(saveReminder) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSave];
    
    self.tableView.tableFooterView = view;
}

- (void)saveReminder {
    self.reminderManager.delegate = self;
    if (SettingModeNew == _settingMode) {
        _reminder.triggerTime = _triggerTime;
        if (![[_reminder.userID stringValue] isEqualToString:[UserManager defaultManager].userID ]) {
            [[MBProgressManager defaultManager] showHUD:@"发送中"];
        }
        [[ReminderManager defaultManager] sendReminder:_reminder];
        
    }else {
        [[ReminderManager defaultManager] modifyReminder:_reminder withTriggerTime:_triggerTime withDesc:_reminder.desc];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (void)initData {
    _tags = [[NSArray alloc] initWithObjects:@"记得做", @"记得带", @"记得买",@"记一下", nil];
    
    if (SettingModeNew == _settingMode) {
        SoundManager * manager = [SoundManager defaultSoundManager];
        _reminder.audioUrl = [manager.recordFileURL relativePath];
        _reminder.audioLength = [NSNumber numberWithInteger:manager.currentRecordTime];
    }
    
    if (SettingModeNew == _settingMode) {
        _reminder.userID = [NSNumber numberWithLongLong:[[[UserManager defaultManager] userID] longLongValue]];
        _receiver = @"自己";
        
    }else {
        _triggerTime = _reminder.triggerTime;
    }
}

- (void)initNavBar {
    UIBarButtonItem * leftItem;
    
    leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeHUD {
    [[MBProgressManager defaultManager] removeHUD];
}

#pragma 类成员函数
- (void)updateReceiverCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    self.title = @"约定";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44.0;
    if (SettingModeNew == _settingMode) {
        _reminder = [[ReminderManager defaultManager] reminder];
    }
    [self initData];
    [self initNavBar];
    _isLogin = [[SinaWeiboManager defaultManager].sinaWeibo isLoggedIn];
    _isAuthValid = [[SinaWeiboManager defaultManager].sinaWeibo isAuthValid];
    [self initTableFooterView];
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
            timeCell.triggerTime = _triggerTime;
            cell = timeCell;
        }else if (indexPath.row == 3){
            cell.textLabel.text = @"发送给";
            cell.detailTextLabel.text = _receiver;
            if (NO == _isLogin) {
                cell.accessoryType = UITableViewCellAccessoryNone;
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
            if (nil != _triggerTime) {
                timeCell.accessoryType = UITableViewCellAccessoryNone;
            }else {
                timeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
         
            [timeCell.pickerView setHidden:YES];
        }else {
            [timeCell.pickerView setHidden:NO];
            timeCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else if (indexPath.row == 3 && YES == _isLogin) {
        ReminderSendingViewController * controller = [[ReminderSendingViewController alloc] initWithNibName:@"ReminderSendingViewController" bundle:nil];
        _reminder.triggerTime =  _triggerTime;
        controller.reminder = _reminder;
        controller.parentController = self;
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

#pragma mark - ReminderManager delegate
- (void)newReminderSuccess:(NSString *)reminderId {
    self.reminderManager.delegate = nil;
    [[MBProgressManager defaultManager] removeHUD];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if ([[_reminder.userID stringValue] isEqualToString:[UserManager defaultManager].userID ]) {
            if (nil == _reminder.triggerTime) {
                [AppDelegate delegate].homeViewController.dataType = DataTypeCollectingBox;
            }else {
                [AppDelegate delegate].homeViewController.dataType = DataTypeRecent;
            }
            
            [[AppDelegate delegate].homeViewController initData];
            [[AppDelegate delegate] checkRemindersExpired];
        }
        
    }];
    //    [self saveSendReminder:reminderId]; move to ReminderManager::sendReminder.不跟界面绑定。
}

- (void)newReminderFailed {
    NSLog(@"newReminderFailed");
    [[MBProgressManager defaultManager] showHUD:@"发送失败"];
    [self performSelector:@selector(removeHUD) withObject:self afterDelay:0.5];
}
@end
