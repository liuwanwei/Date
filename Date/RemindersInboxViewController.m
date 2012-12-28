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
#import "AudioReminderSettingViewController.h"
#import "TextReminderSettingViewController.h"
#import "MBProgressManager.h"
#import "AppDelegate.h"

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
}

@end

@implementation RemindersInboxViewController
@synthesize dataType = _dataType;
@synthesize btnAudio = _btnAudio;
@synthesize btnMode = _btnMode;
@synthesize txtDesc = _txtDesc;
@synthesize toolbar = _toolbar;
@synthesize toolbarView = _toolbarView;

#pragma 私有函数
- (void)initMenuView {
    UIButton * leftButton;
    UIBarButtonItem * item;
    
    leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [leftButton setImage:[UIImage imageNamed:@"navi_menuleft_up"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"navi_menuleft_down"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(leftBarBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    item = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.navigationItem.leftBarButtonItem = item;
}

- (void)addUserId:(NSNumber *)userId {
    if (nil == [_usersIdDictionary objectForKey:[userId stringValue]]) {
        [_usersIdDictionary setValue:userId forKey:[userId stringValue]];
        [_usersIdArray addObject:userId];
    }
}

- (void)registerHandleMessage {
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAuthSuccessMessage:) name:kUserOAuthSuccessMessage object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOnlineFriendsMessage:) name:kOnlineFriendsMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRegisterUserMessage:) name:kGoRegisterUserMessage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRemindersUpdateMessage:) name:kRemindesUpdateMessage
                                               object:nil];
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

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = _toolbar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    _toolbar.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
    
    UIControl *overView = [[UIControl alloc] init];
    overView.tag = 10086;
    overView.backgroundColor = [UIColor clearColor];
    overView.frame = CGRectMake(0, 44, 320, containerFrame.origin.y);
    [overView addTarget:self action:@selector(restoreView) forControlEvents:UIControlEventTouchDown];
    [[[UIApplication sharedApplication] keyWindow] addSubview:overView];
}

-(void) keyboardWillHide:(NSNotification *)note{
    [self restoreView];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = _toolbar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    _toolbar.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

- (void)restoreView {
    UIControl *overView = (UIControl *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:10086];
    [overView removeFromSuperview];
    [_txtDesc resignFirstResponder];
}

- (void)registerForRemoteNotification {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
}

- (void)removeHUD {
    [[MBProgressManager defaultManager] removeHUD];
}

- (void)setInfoMode:(InfoMode)mode {
    _infoMode = mode;
    if (InfoModeAudio == _infoMode) {
        [_btnMode setImage:[UIImage imageNamed:@"feeddetail_toolbar_text_btn"] forState:UIControlStateNormal];
        [_btnMode setImage:[UIImage imageNamed:@"feeddetail_toolbar_text_btn_h"] forState:UIControlStateHighlighted];
        _txtDesc.text = @"";
        [_txtDesc resignFirstResponder];
        _btnAudio.frame = CGRectMake(_btnAudio.frame.origin.x, _btnAudio.frame.origin.y, 240, _btnAudio.frame.size.height);
        _txtDesc.frame = CGRectMake(_txtDesc.frame.origin.x, _txtDesc.frame.origin.y, 0, _txtDesc.frame.size.height);
    }else {
        [_btnMode setImage:[UIImage imageNamed:@"feeddetail_toolbar_phone_btn"] forState:UIControlStateNormal];
        [_btnMode setImage:[UIImage imageNamed:@"feeddetail_toolbar_phone_btn_h"] forState:UIControlStateHighlighted];
        [_txtDesc becomeFirstResponder];
        _txtDesc.frame = CGRectMake(_txtDesc.frame.origin.x, _txtDesc.frame.origin.y, 240, _txtDesc.frame.size.height);
        _btnAudio.frame = CGRectMake(_btnAudio.frame.origin.x, _btnAudio.frame.origin.y, 0, _btnAudio.frame.size.height);
    }
}

- (void)showAudioReminderSettingController {
    AudioReminderSettingViewController * controller = [[AudioReminderSettingViewController alloc] initWithNibName:@"AudioReminderSettingViewController" bundle:nil];
    controller.settingMode = SettingModeNew;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)showTextReminderSettingController {
    TextReminderSettingViewController * controller = [[TextReminderSettingViewController alloc] initWithNibName:@"TextReminderSettingViewController" bundle:nil];
    controller.settingMode = SettingModeNew;
    controller.desc = _context;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)clearGroup {
    NSArray * keys = [self.group allKeys];
    NSArray * reminders;
    NSInteger index = 0;
    for (NSString * key in keys) {
        reminders = [self.group objectForKey:key];
        if ([reminders count] == 0) {
            [self.group removeObjectForKey:key];
            [self.keys removeObjectAtIndex:index];
            return;
        }
        index++;
    }
    
}

#pragma 类成员函数
- (void)showLoginViewController {
    _loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self presentViewController:_loginViewController animated:YES completion:nil];
}

- (void)initData {
    if (DataTypeToday == _dataType) {
        self.title = @"今日提醒";
        self.reminders = [self.reminderManager todayUnFinishedReminders];
    }else if (DataTypeRecent == _dataType) {
        self.title = @"所有提醒";
        self.reminders = [self.reminderManager recentUnFinishedReminders];
    }else if (DataTypeCollectingBox == _dataType) {
        self.title = @"收集箱";
        self.reminders = [self.reminderManager collectingBoxReminders];
    }else if (DataTypeHistory == _dataType) {
        self.title = @"历史";
        self.reminders = [self.reminderManager historyReminders];
    }
    
    if (nil != self.reminders) {
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
                }else {
                    [reminders addObject:reminder];
                }
                
                [self addUserId:reminder.userID];
            }
        }
        _friends = [[BilateralFriendManager defaultManager] friendsWithId:_usersIdArray];
    }else {
        self.group = nil;
        self.keys = nil;
    }
    
    _usersIdArray = nil;
    _usersIdDictionary = nil;
    self.reminders = nil;
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
    _dataType = DataTypeToday;
    _txtDesc.delegate = self;
    [self initMenuView];
    [self setInfoMode:InfoModeAudio];
    [self initData];
    [self registerHandleMessage];
    _toolbarView.frame = CGRectMake(0, 0, _toolbarView.frame.size.width, _toolbarView.frame.size.height);
    if (YES == [_sinaWeiboManager.sinaWeibo isAuthValid]) {
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
        [self showAudioReminderSettingController];
    }
}

- (IBAction)changeInfoMode:(UIButton *)sender {
    if (InfoModeAudio == _infoMode) {
        [self setInfoMode:InfoModeText];
    }else {
        [self setInfoMode:InfoModeAudio];
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
        return  [self custumDateString:[self.keys objectAtIndex:section] withShowDate:YES];
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
        
    }
}

#pragma mark - Table view delegate
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ReminderBaseCell * cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString * audioPath = cell.reminder.audioUrl;
    ReminderSettingViewController * controller;
    if (nil == audioPath || [audioPath isEqualToString:@""]) {
        controller = [[TextReminderSettingViewController alloc] initWithNibName:@"TextReminderSettingViewController" bundle:nil];
    }else {
        controller = [[AudioReminderSettingViewController alloc] initWithNibName:@"AudioReminderSettingViewController" bundle:nil];
    }
    
    controller.reminder = cell.reminder;
    if (DataTypeHistory == _dataType) {
        controller.settingMode = SettingModeShow;
    }else {
        controller.settingMode = SettingModeModify;
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
    [self changeInfoMode:nil];
    [self showTextReminderSettingController];
    return YES;
}

#pragma mark - FriendReminderCell Delegate
- (void)clickFinishButton:(NSIndexPath *)indexPath withReminder:(Reminder *)reminder {
    [[self.group objectForKey:[self.keys objectAtIndex:indexPath.section]] removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self clearGroup];
    
    [self performSelector:@selector(reloadData) withObject:self afterDelay:0.2];
}

@end
