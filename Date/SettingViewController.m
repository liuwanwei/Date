//
//  SettingViewController.m
//  date
//
//  Created by maoyu on 12-12-13.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "SettingViewController.h"
#import "ReminderManager.h"
#import "SinaWeiboManager.h"
#import "UserManager.h"

@interface SettingViewController () {
    NSArray * _appBadgeSignRows;
    AppBadgeMode _appBadgeMode;
    NSArray * _appSnsInfo;
    NSArray * _otherInfo;
}

@end

@implementation SettingViewController
@synthesize tableView = _tableView;

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

- (void)initData {
    _appBadgeMode = [[ReminderManager defaultManager] appBadgeMode];
    _appBadgeSignRows = [[NSArray alloc] initWithObjects:@"不显示",@"今日提醒",@"近期提醒", nil];
    _appSnsInfo = [[NSArray alloc] initWithObjects:@"新浪微博", nil];
    _otherInfo = [[NSArray alloc] initWithObjects:@"退出", nil];
}

- (BOOL)isLogin {
    return [[SinaWeiboManager defaultManager].sinaWeibo isLoggedIn];
}

- (BOOL)isAuthValid {
    return [[SinaWeiboManager defaultManager].sinaWeibo isAuthValid];
}

- (NSString *)sinaNickname {
    return [UserManager defaultManager].screenName;
}

- (void)updateSinaRow {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

/*
 处理 LoginController 授权成功后，发送的消息
 */
- (void)handleOAuthSuccessMessage:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserOAuthSuccessMessage object:nil];
    [[SinaWeiboManager defaultManager] requestUserInfo];
    [[SinaWeiboManager defaultManager] requestBilateralFriends];
    
    [self updateSinaRow];
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
    self.tableView.rowHeight = 44;
    self.title = @"设置";
    [self initMenuView];
    [self initData];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.navigationController.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return _appSnsInfo.count;
        
    }else if (1 == section) {
        return _appBadgeSignRows.count;
    }else if (2 == section) {
        return _otherInfo.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"账号绑定";
    }else if (1 == section) {
        return @"应用程序标记";
    }else if (2 == section) {
        return @"其他";
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (0 == indexPath.section) {
        if (YES == [self isLogin]) {
            if (nil != [self sinaNickname]) {
                NSString * str = [[_appSnsInfo objectAtIndex:0] stringByAppendingString:@" ("];
                str = [str stringByAppendingString:[self sinaNickname]];
                str = [str stringByAppendingString:@")"];
                cell.textLabel.text = str;
            }else {
                cell.textLabel.text = [_appSnsInfo objectAtIndex:0];
            }
            
            if (NO == [self isAuthValid]) {
                cell.detailTextLabel.text = @"过期";
            }
        }else {
            cell.textLabel.text = [_appSnsInfo objectAtIndex:0];
            cell.detailTextLabel.text = @"未绑定";
        }
    }else if (1 == indexPath.section) {
        cell.textLabel.text = [_appBadgeSignRows objectAtIndex:indexPath.row];
        if (_appBadgeMode == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else if (2 == indexPath.section) {
        cell.textLabel.text = @"退出";
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAuthSuccessMessage:) name:kUserOAuthSuccessMessage object:nil];
        [[SinaWeiboManager defaultManager].sinaWeibo logIn];
    }else if (1 == indexPath.section) {
        NSIndexPath * path =  [NSIndexPath indexPathForRow:_appBadgeMode inSection:1];
        UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:path];
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _appBadgeMode = indexPath.row;
        [[ReminderManager defaultManager] storeAppBadgeMode:_appBadgeMode];
    }else if (2 == indexPath.section) {
        [[SinaWeiboManager defaultManager].sinaWeibo logOut];
        [self updateSinaRow];
    }
}

@end
