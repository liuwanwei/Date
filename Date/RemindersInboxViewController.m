//
//  RemindersInboxViewController.m
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "RemindersInboxViewController.h"
#import "ReminderInboxCell.h"
#import "SinaWeiboManager.h"
#import "LoginViewController.h"
#import "OnlineFriendsRemindViewController.h"
#import "ReminderSettingViewController.h"
#import "MBProgressManager.h"
#import "AppDelegate.h"

@interface RemindersInboxViewController () {
    NSMutableDictionary * _group;
    NSMutableArray * _keys;
    NSMutableArray * _usersIdArray;
    NSMutableDictionary * _usersIdDictionary;
    NSDictionary * _friends;
    
    SinaWeiboManager * _sinaWeiboManager;
    UserManager * _userManager;
    LoginViewController * _loginViewController;
    
    NSIndexPath * _curDeleteIndexPath;
}

@end

@implementation RemindersInboxViewController
@synthesize dataType = _dataType;

#pragma 私有函数

- (void)initMenuView {
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnTapped:)];
        self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)showLoginViewController {
    _loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self presentViewController:_loginViewController animated:YES completion:nil];
}

- (void)addUserId:(NSNumber *)userId {
    if (nil == [_usersIdDictionary objectForKey:[userId stringValue]]) {
        [_usersIdDictionary setValue:userId forKey:[userId stringValue]];
        [_usersIdArray addObject:userId];
    }
}

- (void)registerHandleMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAuthSuccessMessage:) name:kUserOAuthSuccessMessage object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOnlineFriendsMessage:) name:kOnlineFriendsMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegisterUserMessage:) name:kGoRegisterUserMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemindersUpdateMessage:) name:kRemindesUpdateMessage object:nil];
}

/*
 处理 LoginController 授权成功后，发送的消息
 */
- (void)handleOAuthSuccessMessage:(NSNotification *)note {
    if (nil != _loginViewController) {
        [_loginViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [_sinaWeiboManager requestUserInfo];
    [_sinaWeiboManager requestBilateralFriends];
}

/*
 处理 BilateralFriendManager 检查到有新注册用户发送的消息
 */
- (void)handleOnlineFriendsMessage:(NSNotification *)note {
    OnlineFriendsRemindViewController * viewController = [[OnlineFriendsRemindViewController alloc] initWithNibName:@"OnlineFriendsRemindViewController" bundle:nil];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)handleRegisterUserMessage:(NSNotification *)note {
    [_userManager registerUserRequest];
}

- (void)handleRemindersUpdateMessage:(NSNotification *)note {
    [self initData];
    [[AppDelegate delegate] checkRemindersExpired];
}

- (void)registerForRemoteNotification {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
}

- (void)removeHUD {
    [[MBProgressManager defaultManager] removeHUD];
}

#pragma 类成员函数
- (void)initData {
    if (DataTypeToday == _dataType) {
        self.title = @"今日提醒";
        self.reminders = [self.reminderManager todayUnFinishedReminders];
    }else if (DataTypeRecent == _dataType) {
        self.title = @"近期提醒";
        self.reminders = [self.reminderManager recentUnFinishedReminders];
    }else if (DataTypeHistory == _dataType) {
        self.title = @"收集箱";
        self.reminders = [self.reminderManager historyReminders];
    }
    
    if (nil != self.reminders) {
        _group = [[NSMutableDictionary alloc] initWithCapacity:0];
        _keys = [[NSMutableArray alloc] initWithCapacity:0];
        _usersIdArray = [[NSMutableArray alloc] initWithCapacity:0];
        _usersIdDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yy-MM-dd"];
        NSMutableArray * reminders;
        NSString * key;
        for (Reminder * reminder in self.reminders) {
            key = [formatter stringFromDate:reminder.triggerTime];
            if (nil != key) {
                if (nil == [_group objectForKey:key]) {
                    reminders = [[NSMutableArray alloc] init];
                    [reminders addObject:reminder];
                    [_group setValue:reminders forKey:key];
                    [_keys addObject:key];
                }else {
                    [reminders addObject:reminder];
                }
                
                [self addUserId:reminder.userID];
            }
        }
        _friends = [[BilateralFriendManager defaultManager] friendsWithId:_usersIdArray];
    }else {
        _group = nil;
        _keys = nil;
        _usersIdArray = nil;
        _usersIdDictionary = nil;
    }
    [self.tableView reloadData];
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _sinaWeiboManager = [SinaWeiboManager defaultManager];
        _userManager = [UserManager defaultManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initMenuView];
    _dataType = DataTypeToday;
    [self initData];
    [self registerHandleMessage];
    
    if (NO == [_sinaWeiboManager.sinaWeibo isAuthValid]) {
        [self showLoginViewController];
    }else {
        [_sinaWeiboManager requestBilateralFriends];
        [[BilateralFriendManager defaultManager] checkRegisteredFriendsRequest];
        [self registerForRemoteNotification];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRecord:(id)sender {
    SoundManager * manager = [SoundManager defaultSoundManager];
    manager.parentView = self.view;
    [manager startRecord];
}

- (IBAction)stopRecord:(id)sender {
    SoundManager * manager = [SoundManager defaultSoundManager];
    if (YES == [manager stopRecord]) {
        ReminderSettingViewController * controller = [[ReminderSettingViewController alloc] initWithNibName:@"ReminderSettingViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil != _group) {
        return [_group count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return  [self custumDateString:[_keys objectAtIndex:section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * reminders = [_group objectForKey:[_keys objectAtIndex:section]];
    if (nil != reminders) {
        return [reminders count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Reminder * reminder = [[_group objectForKey:[_keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    static NSString * CellIdentifier = @"ReminderInboxCell";
    ReminderInboxCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ReminderInboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    
    BilateralFriend * friend = [_friends objectForKey:reminder.userID];
    cell.indexPath = indexPath;
    cell.bilateralFriend = friend;
    cell.reminder = reminder;
    cell.audioState = AudioStateNormal;
    return cell;
}

// Override to support editing the table view.
/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _curDeleteIndexPath = indexPath;
        Reminder * reminder = [[_group objectForKey:[_keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        if ([_userManager.userID isEqualToString:[reminder.userID stringValue]]) {
            [self.reminderManager deleteReminder:reminder];
            [[_group objectForKey:[_keys objectAtIndex:indexPath.section]] removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else {
            [self.reminderManager deleteReminderRequest:reminder];
            [[MBProgressManager defaultManager] showHUD:@"删除中"];
        }
        
    }
}*/

#pragma mark - ReminderManager delegate
- (void)deleteReminderSuccess:(Reminder *)reminder {
    [self.reminderManager deleteReminder:reminder];
    [[_group objectForKey:[_keys objectAtIndex:_curDeleteIndexPath.section]] removeObjectAtIndex:_curDeleteIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_curDeleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [[MBProgressManager defaultManager] removeHUD];
}

- (void)deleteReminderFailed {
    [[MBProgressManager defaultManager] showHUD:@"删除失败"];
    [self performSelector:@selector(removeHUD) withObject:self afterDelay:0.5];
}

@end
