//
//  MenuViewController.m
//  Date
//
//  Created by maoyu on 12-11-30.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "MenuViewController.h"
#import "HttpRequestManager.h"
#import "AppDelegate.h"
#import "RemindersInboxViewController.h"
#import "SettingViewController.h"
#import "SinaWeiboManager.h"
#import "LoginViewController.h"

@interface MenuViewController () {
    ServerMode _serverMode;
    NSArray * _rows;
    NSArray * _rowImages;
    SettingViewController * _settingViewController;
    LoginViewController * _loginViewController;
}

@end

@implementation MenuViewController
@synthesize btnServerMode = _btnServerMode;
@synthesize tableView = _tableView;

#pragma 私有函数
- (BOOL)isLogin {
    return [[SinaWeiboManager defaultManager].sinaWeibo isLoggedIn];
}

- (BOOL)isAuthValid {
    return [[SinaWeiboManager defaultManager].sinaWeibo isAuthValid];
}

#pragma 类成员函数
- (void)setVisible:(BOOL)visible {
    self.view.hidden = !visible;
}

- (void)initServerMode {
    _serverMode = [[HttpRequestManager defaultManager] serverMode];
    if (_serverMode == ServerModeLocal) {
        [_btnServerMode setTitle:@"本地" forState:UIControlStateNormal];
    }else {
        [_btnServerMode setTitle:@"远程" forState:UIControlStateNormal];
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
    [self initServerMode];
    _rows = [[NSArray alloc] initWithObjects:@"今日提醒",@"所有提醒",@"历史", nil];
    _rowImages = [[NSArray alloc] initWithObjects:@"today", @"recently", @"history", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50.0;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sidebar_background"]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)modifyServerMode:(id)sender {
    if (_serverMode == ServerModeLocal) {
        [[HttpRequestManager defaultManager] storeServerMode:ServerModeRemote];
    }else {
        [[HttpRequestManager defaultManager] storeServerMode:ServerModeLocal];
    }
    
    [self initServerMode];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return _rows.count;
    }else{
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"收集";
    }else if (section == 1){
        return @"提醒";
    }else{
        return @"设置";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    UIImage * image = nil;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"收集箱";
    }else if (indexPath.section == 1){
        cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
//        image = [UIImage imageNamed:[_rowImages objectAtIndex:indexPath.row]];
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"设置";
        }else {
            cell.textLabel.text = @"新浪微博绑定";
            if (NO == [self isLogin]) {
                cell.detailTextLabel.text = @"未绑定";
            }else if (NO == [self isAuthValid]) {
                cell.detailTextLabel.text = @"已过期";
            }else {
                cell.detailTextLabel.text = @"已绑定";
            }
        }
    }
    
    cell.imageView.image = image;
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil != _settingViewController) {
        [[AppDelegate delegate].navController popToRootViewControllerAnimated:NO];
        _settingViewController = nil;
    }
    
    if (0 == indexPath.section && 0 == indexPath.row) {
        [AppDelegate delegate].homeViewController.dataType = DataTypeCollectingBox;
    }else if (1 == indexPath.section) {
        uint row = indexPath.row;
        uint types[] = {DataTypeToday, DataTypeRecent, DataTypeHistory};
        [AppDelegate delegate].homeViewController.dataType = types[row];
    }else if (2 == indexPath.section){
        if (0 == indexPath.row) {
            if (_settingViewController == nil) {
                _settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
            }
            
            [[AppDelegate delegate].navController pushViewController:_settingViewController animated:NO];
        }else {
            if (NO == [self isAuthValid]) {
                [[AppDelegate delegate].homeViewController showLoginViewController];
            }
        }
    }
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        [[AppDelegate delegate].homeViewController initData];
    }
    
    [[AppDelegate delegate].homeViewController restoreViewLocation];
}

@end
