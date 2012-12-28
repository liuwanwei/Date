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

@interface ReminderSettingViewController () {
    UIButton * _btnSave;
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

#pragma 私有函数
- (void)initTableFooterView {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 100)];
    _btnSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnSave.layer.frame = CGRectMake(10, 15, 300, 44);
    [_btnSave setBackgroundImage:[UIImage imageNamed:@"buttonBg"] forState:UIControlStateNormal];
    [_btnSave setTitle:@"加入收集" forState:UIControlStateNormal];
    [_btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnSave addTarget:self action:@selector(saveReminder) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_btnSave];
    
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
}

- (void)updateTriggerTimeCell {
}

- (void)initData {
    if (SettingModeNew == _settingMode) {
        _reminder = [[ReminderManager defaultManager] reminder];
        _reminder.userID = [NSNumber numberWithLongLong:[[[UserManager defaultManager] userID] longLongValue]];
        _receiver = @"自己";
    }else {
        _triggerTime = _reminder.triggerTime;
    }
}

- (void)clickTrigeerTimeRow:(NSIndexPath *)indexPath {
    /*self.isSpread = !self.isSpread;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    ReminderSettingTimeCell * timeCell = (ReminderSettingTimeCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (self.isSpread == NO) {
        if (nil != _triggerTime) {
            timeCell.accessoryType = UITableViewCellAccessoryNone;
        }else {
            timeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        [timeCell.pickerView setHidden:YES];
    }else {
        [timeCell.pickerView setHidden:NO];
        timeCell.accessoryType = UITableViewCellAccessoryNone;
    }*/
    
    ReminderTimeSettingViewController * controller = [[ReminderTimeSettingViewController alloc] initWithNibName:@"ReminderTimeSettingViewController" bundle:nil];
    controller.title = @"设置时间";
    controller.parentContoller = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)clickSendRow {
    ReminderSendingViewController * controller = [[ReminderSendingViewController alloc] initWithNibName:@"ReminderSendingViewController" bundle:nil];
    _reminder.triggerTime =  _triggerTime;
    controller.reminder = _reminder;
    controller.parentController = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSString *)stringTriggerTime {
    if (nil != _triggerTime) {
        return [self custumDateTimeString:_triggerTime];
    }
    return @"未设置";
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
    }else {
        if (SettingModeModify == _settingMode) {
            self.title = @"修改提醒";
        }else {
            self.title = @"查看提醒";
        }
        [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
    }
    [self initData];
    _isLogin = [[SinaWeiboManager defaultManager].sinaWeibo isLoggedIn];
    _isAuthValid = [[SinaWeiboManager defaultManager].sinaWeibo isAuthValid];
    [self initTableFooterView];
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

#define IsZero(float) (float > - 0.000001 && float < 0.000001)

#pragma mark - ChoiceViewDelegate
-(void)choiceViewController:(ChoiceViewController *)choiceViewController gotChoice:(NSArray *)choices{
    _reminder.desc = [choices objectAtIndex:0];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
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
