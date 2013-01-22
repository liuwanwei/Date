//
//  RemindersInboxViewController.m
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "RemindersInboxViewController.h"
#import "ReminderInboxCell.h"
#import "TodayReminderCell.h"
#import "ReminderBaseCell.h"
#import "HistoryReminderCell.h"
#import "SinaWeiboManager.h"
#import "LoginViewController.h"
#import "OnlineFriendsRemindViewController.h"
#import "AudioReminderSettingViewController.h"
#import "ModifyTextReminderViewController.h"
#import "NewTextReminderViewController.h"
#import "NewAudioReminderViewController.h"
#import "ModifyAudioReminderViewController.h"
#import "MBProgressManager.h"
#import "AppDelegate.h"
#import "ShowTextReminderViewController.h"
#import "ShowAudioReminderViewController.h"
#import "GlobalFunction.h"

@interface RemindersInboxViewController () {
    NSMutableArray * _usersIdArray;
    NSMutableDictionary * _usersIdDictionary;
    NSDictionary * _friends;
    
    SinaWeiboManager * _sinaWeiboManager;
    UserManager * _userManager;
    LoginViewController * _loginViewController;
    
    NSIndexPath * _curDeleteIndexPath;
    InfoMode _infoMode;
    NSString * _context;
    
    EGORefreshTableHeaderView * _refreshHeaderView;
    BOOL _reloading;
    UIControl * _overView;
}

@end

@implementation RemindersInboxViewController
@synthesize dataType = _dataType;
@synthesize btnAudio = _btnAudio;
@synthesize btnMode = _btnMode;
@synthesize txtDesc = _txtDesc;
@synthesize toolbar = _toolbar;
@synthesize toolbarView = _toolbarView;
@synthesize labelPrompt = _labelPrompt;

#pragma 私有函数
- (void)addUserId:(NSNumber *)userId {
    if (nil == [_usersIdDictionary objectForKey:[userId stringValue]]) {
        [_usersIdDictionary setValue:userId forKey:[userId stringValue]];
        [_usersIdArray addObject:userId];
    }
}

- (void)registerHandleMessage {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOnlineFriendsMessage:) name:kOnlineFriendsMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRemindersUpdateMessage:) name:kRemindesUpdateMessage
                                               object:nil];
}

/*
 处理 BilateralFriendManager 检查到有新注册用户发送的消息
 */
- (void)handleOnlineFriendsMessage:(NSNotification *)note {
    OnlineFriendsRemindViewController * viewController = [[OnlineFriendsRemindViewController alloc] initWithNibName:@"OnlineFriendsRemindViewController" bundle:nil];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)handleRemindersUpdateMessage:(NSNotification *)note {
    [self initDataWithAnimation:NO];
}

- (void)restoreView {
    [_overView removeFromSuperview];
    _overView = nil;
    [_txtDesc resignFirstResponder];
   
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    
    // set views with new info
    self.navigationController.navigationBarHidden = NO;
    [_txtDesc setHidden:YES];
    // commit animations
    [UIView commitAnimations];
}

- (void)registerForRemoteNotification {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
}

- (void)removeHUD {
    [[MBProgressManager defaultManager] removeHUD];
}

- (void)showAudioReminderSettingController {
    NewAudioReminderViewController * controller = [[NewAudioReminderViewController alloc] initWithNibName:@"AudioReminderSettingViewController" bundle:nil];
    controller.dateType = _dataType;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [[GlobalFunction defaultGlobalFunction] setNavigationBarBackgroundImage:nav.navigationBar];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)showTextReminderSettingController {
    NewTextReminderViewController * controller = [[NewTextReminderViewController alloc] initWithNibName:@"TextReminderSettingViewController" bundle:nil];
    controller.desc = _context;
    controller.dateType = _dataType;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [[GlobalFunction defaultGlobalFunction] setNavigationBarBackgroundImage:nav.navigationBar];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)reloadData {
    [self.tableView reloadData];
    if ([self.group count] == 0) {
        [_labelPrompt setHidden:NO];
    }else {
        [_labelPrompt setHidden:YES];
    }
}

- (void)clearGroup {
    NSArray * reminders;
    NSInteger index;
    NSInteger count;
    NSString * key;
    if (nil != self.keys) {
        count = [self.keys count];
        for (index = 0; index < count; index ++) {
            key = [self.keys objectAtIndex:index];
            reminders = [self.group objectForKey:key];
            if ([reminders count] == 0) {
                [self.group removeObjectForKey:key];
                [self.keys removeObjectAtIndex:index];
                return;
            }
        }
    }
}

- (void)initView {
    _txtDesc.frame = CGRectMake(_txtDesc.frame.origin.x, _txtDesc.frame.origin.y, _txtDesc.frame.size.width, 60);
    [_txtDesc setHidden:YES];
    _txtDesc.delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [_toolbar setBackgroundImage:[UIImage imageNamed:@"navigationBarBg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)addRefreshHeaderView {
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
}

- (void)removeRefreshHeadView {
    [_refreshHeaderView removeFromSuperview];
    _refreshHeaderView = nil;
}

#pragma 类成员函数
- (void)initDataWithAnimation:(BOOL)animation {
    [_toolbar setHidden:NO];
    [self addRefreshHeaderView];
    self.tableView.frame =CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width,self.view.frame.size.height - _toolbar.frame.size.height);
    if (DataTypeToday == _dataType) {
        self.title = @"今日提醒";
        self.reminders = [self.reminderManager todayUnFinishedReminders];
    }else if (DataTypeRecent == _dataType) {
        self.title = @"所有提醒";
        self.reminders = [self.reminderManager recentUnFinishedReminders];
    }else if (DataTypeCollectingBox == _dataType) {
        self.title = LocalString(@"DraftBox");
        self.reminders = [self.reminderManager collectingBoxReminders];
    }else if (DataTypeHistory == _dataType) {
        self.title = @"已完成";
        [self removeRefreshHeadView];
        [_toolbar setHidden:YES];
        self.tableView.frame =CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width,self.view.frame.size.height);
        self.reminders = [self.reminderManager historyReminders];
    }
    
    if (nil != self.reminders) {
        [_labelPrompt setHidden:YES];
        self.group = nil;
        self.keys = nil;
        self.group = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.keys = [[NSMutableArray alloc] initWithCapacity:0];
        _usersIdArray = [[NSMutableArray alloc] initWithCapacity:0];
        _usersIdDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yy-MM-dd"];
        NSMutableArray * reminders;
        NSString * key;
        NSIndexSet * indexSet;
        NSInteger indexSection  = 0;
        if (YES == animation) {
            [self.tableView reloadData];
            [self.tableView beginUpdates];
        }
        for (Reminder * reminder in self.reminders) {
            if (nil == reminder.triggerTime) {
                key = [formatter stringFromDate:reminder.createTime];
            }else {
                key = [formatter stringFromDate:reminder.triggerTime];
            }
            
            if (nil != key) {
                if (nil == [self.group objectForKey:key]) {
                    reminders = [[NSMutableArray alloc] init];
                    [reminders addObject:reminder];
                    [self.group setValue:reminders forKey:key];
                    [self.keys addObject:key];
                    
                    if (YES == animation) {
                        indexSet = [[NSIndexSet alloc] initWithIndex:indexSection];
                        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
                     }
                    
                    indexSection ++;
                }else {
                    [reminders addObject:reminder];
                }
                
                [self addUserId:reminder.userID];
            }
        }
        _friends = [[BilateralFriendManager defaultManager] friendsWithId:_usersIdArray];
        if (YES == animation) {
            [self.tableView endUpdates];
        }
        
    }else {
        self.group = nil;
        self.keys = nil;
        [self.tableView reloadData];
        [_labelPrompt setHidden:NO];
    }
    
    _usersIdArray = nil;
    _usersIdDictionary = nil;
    self.reminders = nil;
    if (animation == NO) {
        [self.tableView reloadData];
    }

}

- (void)computeRemindersSize{
    [self.reminderManager computeRemindersSize];
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
    
    _dataType = DataTypeToday;
    [self initMenuButton];
    [self initDataWithAnimation:YES];
    [self registerHandleMessage];
    [self initView];
    [self performSelector:@selector(computeRemindersSize) withObject:self afterDelay:0.5];
    if (YES == [_sinaWeiboManager.sinaWeibo isAuthValid]) {
        [_sinaWeiboManager requestBilateralFriends];
        [[BilateralFriendManager defaultManager] checkRegisteredFriendsRequest];
        [self registerForRemoteNotification];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
        [self showAudioReminderSettingController];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil != self.group) {
        return [self.group count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (DataTypeToday != _dataType) {
        return  [[GlobalFunction defaultGlobalFunction] custumDateString:[self.keys objectAtIndex:section] withShowDate:YES];
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * reminders = [self.group objectForKey:[self.keys objectAtIndex:section]];
    if (nil != reminders) {
        return [reminders count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Reminder * reminder = [[self.group objectForKey:[self.keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    static NSString * CellIdentifier;
    ReminderBaseCell * cell;
    if (DataTypeToday == _dataType || DataTypeRecent == _dataType) {
        CellIdentifier = @"TodayReminderCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[TodayReminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }else if (DataTypeHistory == _dataType) {
        CellIdentifier = @"HistoryReminderCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[HistoryReminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }else if (DataTypeCollectingBox == _dataType) {
        CellIdentifier = @"ReminderInboxCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ReminderInboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    
    cell.delegate = self;
    
    BilateralFriend * friend = [_friends objectForKey:reminder.userID];
    cell.dateType = _dataType;
    cell.indexPath = indexPath;
    cell.bilateralFriend = friend;
    cell.reminder = reminder;
    cell.audioState = AudioStateNormal;
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _curDeleteIndexPath = indexPath;
        Reminder * reminder = [[self.group objectForKey:[self.keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        NSString * userId = [reminder.userID stringValue];
        if ([userId isEqualToString:@"0"] ||
            [_userManager.userID isEqualToString:userId]) {
            [self.reminderManager deleteReminder:reminder];
            [[self.group objectForKey:[self.keys objectAtIndex:indexPath.section]] removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self clearGroup];
            [self performSelector:@selector(reloadData) withObject:self afterDelay:0.2];
        }else {
            [self.reminderManager deleteReminderRequest:reminder];
            [[MBProgressManager defaultManager] showHUD:@"删除中"];
        }
    }else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"begin editing");
    ReminderBaseCell * cell = (ReminderBaseCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.editingState = CellEditingStateDelete;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"end editing");
    ReminderBaseCell * cell = (ReminderBaseCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.editingState = CellEditingStateDefault;
}

#pragma mark - Table view delegate
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ReminderBaseCell * cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString * audioPath = cell.reminder.audioUrl;
    
    ReminderSettingViewController * controller;
    if (DataTypeHistory == _dataType || (NO == [_userManager isOneself:[cell.reminder.userID stringValue]] && nil != cell.reminder.triggerTime)) {
        if (nil == audioPath || [audioPath isEqualToString:@""]) {
            controller = [[ShowTextReminderViewController alloc] initWithNibName:@"TextReminderSettingViewController" bundle:nil];
        }else {
            controller = [[ShowAudioReminderViewController alloc] initWithNibName:@"AudioReminderSettingViewController" bundle:nil];
        }
        
    }else {
        if (nil == audioPath || [audioPath isEqualToString:@""]) {
            controller = [[ModifyTextReminderViewController alloc] initWithNibName:@"TextReminderSettingViewController" bundle:nil];
        }else {
            controller = [[ModifyAudioReminderViewController alloc] initWithNibName:@"AudioReminderSettingViewController" bundle:nil];
        }
        
        if (DataTypeCollectingBox == _dataType) {
            controller.isInbox = YES;
        }else {
            controller.isInbox = NO;
        }
    }
    
    controller.reminder = cell.reminder;
    controller.dateType = _dataType;
    if (YES == [_userManager isOneself:[cell.reminder.userID stringValue]]) {
        controller.receiver = @"自己";
    }else if (nil != cell.bilateralFriend) {
        controller.receiver = cell.bilateralFriend.nickname;
    }else {
        controller.receiver = [cell.reminder.userID stringValue];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - ReminderManager delegate
- (void)deleteReminderSuccess:(Reminder *)reminder {
    [self.reminderManager deleteReminder:reminder];
    
    [[self.group objectForKey:[self.keys objectAtIndex:_curDeleteIndexPath.section]] removeObjectAtIndex:_curDeleteIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_curDeleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [[MBProgressManager defaultManager] removeHUD];
    [self clearGroup];
    [self performSelector:@selector(reloadData) withObject:self afterDelay:0.2];
}

- (void)deleteReminderFailed {
    [[MBProgressManager defaultManager] showHUD:@"删除失败"];
    [self performSelector:@selector(removeHUD) withObject:self afterDelay:0.5];
}

#pragma mark - UITextFiled delegte 
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    _context = _txtDesc.text;
    [self restoreView];
    [self showTextReminderSettingController];
    _txtDesc.text = @"";
    return YES;
}

#pragma mark - FriendReminderCell Delegate
- (void)clickFinishButton:(NSIndexPath *)indexPath withReminder:(Reminder *)reminder {
    [[self.group objectForKey:[self.keys objectAtIndex:indexPath.section]] removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self clearGroup];
    
    [self performSelector:@selector(reloadData) withObject:self afterDelay:0.2];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
		
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    _reloading = YES;
    if (nil == _overView) {
        _overView = [[UIControl alloc] init];
        _overView.backgroundColor = [UIColor whiteColor];
        _overView.frame = CGRectMake(0, 60, 320,self.view.bounds.size.height - 60);
        [_overView addTarget:self action:@selector(restoreView) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_overView];
    }
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];
    
    // set views with new info
    _overView.backgroundColor = [UIColor blackColor];
    _overView.alpha = 0.8;
    self.navigationController.navigationBarHidden = YES;
    [_txtDesc setHidden:NO];
    // commit animations
    [UIView commitAnimations];
    [_txtDesc becomeFirstResponder];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.01];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

@end
