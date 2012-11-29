//
//  HomeViewController.m
//  yueding
//
//  Created by maoyu on 12-11-8.
//  Copyright (c) 2012年 maoyu. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UserManager.h"
#import "SinaWeiboManager.h"
#import "OnlineFriendsRemindViewController.h"
#import "BilateralFriendManager.h"
#import "BilateralFriend.h"
#import "ReminderManager.h"
#import "EGOImageView.h"
#import "SoundManager.h"
#import "ReminderSettingViewController.h"
#import "HttpRequestManager.h"
#import "FriendRemindersViewController.h"

@interface HomeViewController () {
    SinaWeiboManager * _sinaWeiboManager;
    UserManager * _userManager;
    ReminderManager * _reminderManager;
    LoginViewController * _loginViewController;
    NSArray * _friends;
    NSDictionary * _reminders;
}

@end

@implementation HomeViewController
@synthesize tableView = _tableView;
@synthesize homeCell = _homeCell;

#pragma 私有函数

- (void)showLoginViewController {
    _loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self presentViewController:_loginViewController animated:YES completion:nil];
}

- (void)registerHandleMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAuthSuccessMessage:) name:kUserOAuthSuccessMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOnlineFriendsMessage:) name:kOnlineFriendsMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegisterUserMessage:) name:kGoRegisterUserMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemindersUpdateMessage:) name:kRemindesUpdateMessage object:nil];
}

- (void)initFriends {
    if (nil != _friends) {
        _friends = nil;
    }
    
    _friends = [[BilateralFriendManager defaultManager] haveReminderFriends];
}

- (void)initReminders {
    if (nil != _friends) {
        NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
        for (BilateralFriend * friend in _friends) {
            [array addObject:friend.lastReminderID];
        }
        
        _reminders = [[ReminderManager defaultManager] remindersWithId:array];
        
        if (nil != _reminders) {
            [self.tableView reloadData];
        }
    }
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
    [[HttpRequestManager defaultManager] registerUserRequest];
}

- (void)handleRemindersUpdateMessage:(NSNotification *)note {
    [self initFriends];
    [self initReminders];
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _sinaWeiboManager = [SinaWeiboManager defaultManager];
        _userManager = [UserManager defaultManager];
        _reminderManager = [ReminderManager defaultManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60.0;
    self.title = @"约定";
    
    [self initFriends];
    [self initReminders];
    [self registerHandleMessage];
    if (NO == [_sinaWeiboManager.sinaWeibo isAuthValid]) {
        [self showLoginViewController];
    }else {
        [_sinaWeiboManager requestBilateralFriends];
        [[BilateralFriendManager defaultManager] checkRegisteredFriendsRequest];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        ReminderSettingViewController * controller = [[ReminderSettingViewController alloc] initWithNibName:@"ReminderSettingViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    EGOImageView * imageView;
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
        cell = _homeCell;
        self.homeCell = nil;
        
    }
    imageView = (EGOImageView *)[cell viewWithTag:TagsHomeCellImage];
    [imageView  setPlaceholderImage:[UIImage imageNamed:@"male"]];
    
    BilateralFriend * friend = [_friends objectAtIndex:indexPath.row];
    if (nil != friend.imageUrl) {
        [imageView setImageURL:[NSURL URLWithString:friend.imageUrl]];
    }
    
    UIButton * btnBadge = (UIButton *)[cell viewWithTag:TagsHomeCellBadge];
    if (nil != friend.unReadRemindersSize) {
        NSInteger size = [friend.unReadRemindersSize integerValue];
        if (size > 0) {
            [btnBadge setHidden:NO];
            [btnBadge setTitle:[NSString stringWithFormat: @"%d", size] forState:UIControlStateNormal];
        }else {
            [btnBadge setHidden:YES];
        }
    }else {
        [btnBadge setHidden:YES];
    }
    
    UILabel * nicknameLabel = (UILabel *)[cell viewWithTag:TagsHomeCellNickname];
    nicknameLabel.text = friend.nickname;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendRemindersViewController * controller = [[FriendRemindersViewController alloc] initWithNibName:@"FriendRemindersViewController" bundle:nil];
    BilateralFriend * friend = [_friends objectAtIndex:indexPath.row];
    controller.userId = friend.userID;
    controller.bilateralFriend = friend;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
