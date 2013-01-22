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
#import "BilateralFriendManager.h"
#import "SettingAppBadgeViewController.h"
#import "SettingSNSViewController.h"
#import "SettingAlertSound.h"

@interface SettingViewController () {
    NSArray * _otherInfo;
}

@end

@implementation SettingViewController
@synthesize tableView = _tableView;
@synthesize appBadgeSignRows = _appBadgeSignRows;
@synthesize appBadgeMode = _appBadgeMode;
@synthesize appSnsInfo = _appSnsInfo;

#pragma 私有函数
- (void)initData {
    _appBadgeMode = [[ReminderManager defaultManager] appBadgeMode];
    _appBadgeSignRows = [[NSArray alloc] initWithObjects:@"不显示",@"今日提醒",@"所有提醒", nil];
    _appSnsInfo = [[NSArray alloc] initWithObjects:@"新浪微博", nil];
    _otherInfo = [[NSArray alloc] initWithObjects:@"退出", nil];
}

- (void)updateSNSCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma 类成员函数
- (void)updateAppBadgeCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)refreshTable:(NSNotification *)notification{
    if (nil != notification) {
        NSDictionary * userInfo = notification.userInfo;
        int section = [((NSNumber *)[userInfo objectForKey:@"section"]) intValue];
        int row = [((NSNumber *)[userInfo objectForKey:@"row"]) intValue];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
    [self initMenuButton];
    [self initData];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:UINotificationRefreshCell object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (0 == indexPath.section) {
        //cell.imageView.image = [UIImage imageNamed:@"sinaWeiboLogo"];
        cell.textLabel.text = LocalString(@"SettingAppSNSBinding");
        if (YES == [self isLogin]) {
            if (NO == [self isAuthValid]) {
                cell.detailTextLabel.text = @"已过期";
            }else {
                cell.detailTextLabel.text = @"已绑定";
            }
        }else {
            cell.detailTextLabel.text = @"未绑定";
        }
    }else if (1 == indexPath.section) {
        //cell.imageView.image = [UIImage imageNamed:@"notification"];
        cell.textLabel.text = @"应用程序标记";
        cell.detailTextLabel.text = [_appBadgeSignRows objectAtIndex:_appBadgeMode];
    }else if(2 == indexPath.section){
        cell.textLabel.text = @"提醒声音";
        SoundManager * soundManager = [SoundManager defaultSoundManager];
        cell.detailTextLabel.text = [soundManager alertSoundTitleForType:soundManager.alertSound];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (0 == indexPath.section) {
        SettingSNSViewController * controller = [[SettingSNSViewController alloc] initWithNibName:@"SettingSNSViewController" bundle:nil];
        controller.parentController = self;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if (1 == indexPath.section) {
        SettingAppBadgeViewController * controller = [[SettingAppBadgeViewController alloc] initWithNibName:@"SettingAppBadgeViewController" bundle:nil];
        controller.parentController = self;
        [self.navigationController pushViewController:controller animated:YES];
    }else if (2 == indexPath.section){
        SettingAlertSound * contoller = [[SettingAlertSound alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:contoller animated:YES];
    }
}

@end
