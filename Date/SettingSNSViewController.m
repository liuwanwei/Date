//
//  SettingSNSViewController.m
//  date
//
//  Created by maoyu on 13-1-10.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "SettingSNSViewController.h"
#import "GlobalFunction.h"
#import "SinaWeiboManager.h"
#import "MobClick.h"

@interface SettingSNSViewController ()

@end

@implementation SettingSNSViewController
@synthesize tableView = _tableView;
@synthesize parentController = _parentController;

#pragma 私有函数
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 处理 LoginController 授权成功后，发送的消息
 */
- (void)handleOAuthSuccessMessage:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserOAuthSuccessMessage object:nil];
    [[SinaWeiboManager defaultManager] requestUserInfo];
    [[SinaWeiboManager defaultManager] requestBilateralFriends];
    
    [_parentController updateSNSCell];
    
    if (nil == [[BilateralFriendManager defaultManager] allFriendsID]) {
        [MobClick event:kUMengEventSinaWeiboBinding];
    }
    [self back];
}

- (void)initTableFooterView {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 100)];
    
    UIButton * btnRelieve = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnRelieve.layer.frame = CGRectMake(10, 30, 300, 44);
    btnRelieve.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [btnRelieve setBackgroundImage:[UIImage imageNamed:@"deleteBtn"] forState:UIControlStateNormal];
    [btnRelieve setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRelieve setTitle:LocalString(@"SettingAppSNSRelieve") forState:UIControlStateNormal];
    [btnRelieve addTarget:self action:@selector(relieveSNS) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnRelieve];
    
    self.tableView.tableFooterView = view;
}

- (void)relieveSNS {
    long long userId = [[SinaWeiboManager defaultManager].sinaWeibo.userID longLongValue];
    BilateralFriend * friend = [[BilateralFriendManager defaultManager]
                                bilateralFriendWithUserID:[NSNumber numberWithLongLong:userId]];
    if (nil != friend) {
        [[BilateralFriendManager defaultManager] deleteFriend:friend];
    }
    
    [[SinaWeiboManager defaultManager].sinaWeibo logOut];
    [_parentController updateSNSCell];
    [self back];
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
    self.title  = LocalString(@"SettingAppSNSBinding");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (YES == [_parentController isLogin]) {
        [self initTableFooterView];
    }
    [[GlobalFunction defaultInstance] initNavleftBarItemWithController:self withAction:@selector(back)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITabeView DataSource Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return [_parentController.appSnsInfo count];
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"绑定账号后，就可以向互相关注的好友发送闹铃提醒";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (0 == indexPath.section) {
        cell.imageView.image = [UIImage imageNamed:@"sinaWeiboLogo"];
        cell.textLabel.text = [_parentController.appSnsInfo objectAtIndex:indexPath.row];
        if (YES == [_parentController isLogin]) {
            if (nil != [_parentController sinaNickname]) {
                NSString * str = [_parentController sinaNickname];
                if (NO == [_parentController isAuthValid]) {
                    str = [str stringByAppendingString:@" (已过期)"];
                }
                cell.detailTextLabel.text = str;
            }else {
                cell.detailTextLabel.text = @"已绑定";
            }
        }else {
            cell.detailTextLabel.text = @"未绑定";
        }
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        if (YES == [_parentController isAuthValid]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAuthSuccessMessage:) name:kUserOAuthSuccessMessage object:nil];
        [[SinaWeiboManager defaultManager].sinaWeibo logIn];
    }
}

@end
