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

@interface HomeViewController () {
    SinaWeiboManager * _sinaWeiboManager;
    UserManager * _userManager;
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
    [self presentViewController:viewController animated:YES completion:nil];

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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60.0;
    
    [self initFriends];
    [self initReminders];
    [self registerHandleMessage];
    if (NO == [_sinaWeiboManager.sinaWeibo isAuthValid]) {
        [self showLoginViewController];
    }else {
        [_sinaWeiboManager requestBilateralFriends];
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
        
        imageView = (EGOImageView *)[cell viewWithTag:TagsHomeCellImage];
        [imageView  setPlaceholderImage:[UIImage imageNamed:@"male"]];
    } else {
        imageView = (EGOImageView *)[cell viewWithTag:TagsHomeCellImage];
    }
    
    BilateralFriend * friend = [_friends objectAtIndex:indexPath.row];
    if (nil != friend.imageUrl) {
        [imageView setImageURL:[NSURL URLWithString:friend.imageUrl]];
    }
    
    UILabel * nicknameLabel = (UILabel *)[cell viewWithTag:UIFriendNameTag];
    nicknameLabel.text = friend.nickname;
    
    return cell;
}
@end
