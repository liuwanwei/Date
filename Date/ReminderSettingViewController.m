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
#import "SinaWeiboManager.h"
#import "MBProgressManager.h"
#import "AppDelegate.h"
#import "RemindersInboxViewController.h"
#import "ReminderTimeSettingViewController.h"
#import "LMLibrary.h"

#define kPromptInbox @"信息将加入本地收集箱中"
#define kPromptAlarm @"信息将加入本地提醒中"
#define kPromptSend @"提醒将发送给您的朋友"

typedef enum {
    OperateInbox = 0,
    OperateAlarm,
    OperateSend
}Operate;

@interface ReminderSettingViewController () {
    UIButton * _btnSave;
    UILabel * _labelPrompt;
    UserManager * _userManager;
    UIDatePicker * _datePicker;
    Operate _operate;
}

@end

@implementation ReminderSettingViewController
@synthesize tableView = _tableView;
@synthesize pickerView = _pickerView;
@synthesize settingMode = _settingMode;
@synthesize reminder = _reminder;
@synthesize receiver = _receiver;
@synthesize desc = _desc;
@synthesize triggerTime = _triggerTime;
@synthesize isLogin = _isLogin;
@synthesize isAuthValid = _isAuthValid;
@synthesize isSpread = _isSpread;
@synthesize receiverId = _receiverId;

#pragma 私有函数
- (void)initTableFooterView {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 100)];
    
    _labelPrompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
    _labelPrompt.backgroundColor = [UIColor clearColor];
    _labelPrompt.textAlignment = NSTextAlignmentCenter;
    _labelPrompt.textColor = RGBColor(153,153,153);
    [view addSubview:_labelPrompt];
    
    _btnSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnSave.layer.frame = CGRectMake(10, 30, 300, 44);
    _btnSave.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_btnSave setBackgroundImage:[UIImage imageNamed:@"buttonBg"] forState:UIControlStateNormal];
    [_btnSave setTitle:@"加入收集" forState:UIControlStateNormal];
    [_btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnSave addTarget:self action:@selector(saveReminder) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_btnSave];
    
    self.tableView.tableFooterView = view;
}

- (void)updateTableFooterView {
    if (nil != _triggerTime) {
        if (YES == [[UserManager defaultManager] isOneself:[_receiverId stringValue]] ) {
            _labelPrompt.text = kPromptAlarm;
            [_btnSave setTitle:@"加入提醒" forState:UIControlStateNormal];
        }else {
            _labelPrompt.text = kPromptSend;
            [_btnSave setTitle:@"发送提醒" forState:UIControlStateNormal];
        }
    }else {
        _labelPrompt.text = kPromptInbox;
        [_btnSave setTitle:@"加入收集" forState:UIControlStateNormal];
    }
}

- (void)saveReminder {
    self.reminderManager.delegate = self;
    if (SettingModeNew == _settingMode) {
        _reminder.userID = _receiverId;
        _reminder.triggerTime = _triggerTime;
        _reminder.desc = _desc;
        if (NO == [_userManager isOneself:[_reminder.userID stringValue]] &&
            nil != _reminder.triggerTime) {
            [[MBProgressManager defaultManager] showHUD:@"发送中"];
        }
        [[ReminderManager defaultManager] sendReminder:_reminder];
        
    }else {
        _reminder.userID = _receiverId;
        if (YES == [_userManager isOneself:[_receiverId stringValue]] ||
            nil == _triggerTime) {
             [[ReminderManager defaultManager] modifyReminder:_reminder withTriggerTime:_triggerTime withDesc:_desc];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            _reminder.triggerTime = _triggerTime;
            _reminder.desc = _desc;
            [[MBProgressManager defaultManager] showHUD:@"发送中"];
            [[ReminderManager defaultManager] sendReminder:_reminder];
        }
    
    }
}

- (void)initNavBar {
    UIBarButtonItem * leftItem;
    leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:^ {
        [[AppDelegate delegate] checkRemindersExpired];
    }];
}

- (void)removeHUD {
    [[MBProgressManager defaultManager] removeHUD];
}

- (void)initDatePicker {
    if (nil == _datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [_datePicker setMinuteInterval:5];
    }
}

#pragma 类成员函数
- (void)updateReceiverCell {
    [self updateTableFooterView];
}

- (void)updateTriggerTimeCell {
    [self updateTableFooterView];
}

- (void)updateDescCell {
}

- (void)initData {
    _userManager = [UserManager defaultManager];
    if (SettingModeNew == _settingMode) {
        _reminder = [[ReminderManager defaultManager] reminder];
        _receiverId = [NSNumber numberWithLongLong:[[UserManager defaultManager].oneselfId longLongValue]];
        _receiver = @"自己";
    }else {
        _receiverId = _reminder.userID;
        _triggerTime = _reminder.triggerTime;
        _desc = _reminder.desc;
    }
}

- (void)clickTrigeerTimeRow:(NSIndexPath *)indexPath {
    ReminderTimeSettingViewController * timeSettingController;
    timeSettingController = [[ReminderTimeSettingViewController alloc] initWithNibName:@"ReminderTimeSettingViewController" bundle:nil];
    timeSettingController.title = @"设置时间";
    timeSettingController.parentContoller = self;
    timeSettingController.datePick = _datePicker;
    [self.navigationController pushViewController:timeSettingController animated:YES];
}

- (void)clickSendRow {
    ReminderSendingViewController * controller = [[ReminderSendingViewController alloc] initWithNibName:@"ReminderSendingViewController" bundle:nil];
    _reminder.triggerTime =  _triggerTime;
    controller.reminder = _reminder;
    controller.parentController = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSString *)stringTriggerTime {
    NSString * result;
    if (nil != _triggerTime) {
        result =  [self custumDateTimeString:_triggerTime];
    }else {
        result = @"未设置";
    }

    return result;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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
    if (SettingModeNew == _settingMode) {
        self.title = @"新建提醒";
        [self initNavBar];
        [self initTableFooterView];
    }else {
        if (SettingModeModify == _settingMode) {
            self.title = @"修改提醒";
            [self initTableFooterView];
        }else {
            self.title = @"查看提醒";
        }
        [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
    }
    [self initData];
    [self updateTableFooterView];
    _isLogin = [[SinaWeiboManager defaultManager].sinaWeibo isLoggedIn];
    _isAuthValid = [[SinaWeiboManager defaultManager].sinaWeibo isAuthValid];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initDatePicker];
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

#define IsZero(float) (float > - 0.000001 && float < 0.000001)

#pragma mark - ChoiceViewDelegate
-(void)choiceViewController:(ChoiceViewController *)choiceViewController gotChoice:(NSArray *)choices{
    self.desc = [choices objectAtIndex:0];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - ReminderManager delegate
- (void)newReminderSuccess:(NSString *)reminderId {
    self.reminderManager.delegate = nil;
    [[MBProgressManager defaultManager] removeHUD];
    if (NO == [_userManager isOneself:[_reminder.userID stringValue]] && nil != _reminder.triggerTime) {
        _reminder.id = reminderId;
        [self.reminderManager modifyReminder:_reminder withType:ReminderTypeSend];
    }
    if (SettingModeModify == _settingMode) {
        [[AppDelegate delegate].homeViewController initDataWithAnimation:NO];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (YES == [_userManager isOneself:[_reminder.userID stringValue]] ||
                nil == _reminder.triggerTime) {
                /*if (nil == _reminder.triggerTime) {
                    [AppDelegate delegate].homeViewController.dataType = DataTypeCollectingBox;
                }else {
                    [AppDelegate delegate].homeViewController.dataType = DataTypeRecent;
                }*/
                
                [[AppDelegate delegate].homeViewController initDataWithAnimation:NO];
                [[AppDelegate delegate] checkRemindersExpired];
            }
            
        }];
    }
}

- (void)newReminderFailed {
    NSLog(@"newReminderFailed");
    [[MBProgressManager defaultManager] showHUD:@"发送失败"];
    [self performSelector:@selector(removeHUD) withObject:self afterDelay:0.5];
}
@end
