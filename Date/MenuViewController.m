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
#import "LMLibrary.h"
#import "GlobalFunction.h"

typedef enum {
    MenuCellTagTitle = 1,
    MenuCellTagStart,
    MenuCellTagSeparate
}MenuCellTag;

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
@synthesize menuCell = _menuCell;

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
    _rows = [[NSArray alloc] initWithObjects:@"今日提醒",@"所有提醒",@"已完成", nil];
    _rowImages = [[NSArray alloc] initWithObjects:@"today", @"recently", @"history", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50.0;
    //[self.tableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"sidebar_separate_light"]]];
    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:0];
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
    //return 3;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*if (section == 0) {
        return 1;
    }else if (section == 1){
        return _rows.count;
    }else{
        return 1;
    }*/
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    /*if (section == 0) {
        return @"收集";
    }else if (section == 1){
        return @"提醒";
    }else{
        return @"设置";
    }*/
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"MenuCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
        cell = self.menuCell;
        _menuCell = nil;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sidebar_cellhighlighted_bg"]];
    }

    UILabel * labelTitle = (UILabel *)[cell viewWithTag:MenuCellTagTitle];
    UIImageView * imageStart = (UIImageView *)[cell viewWithTag:MenuCellTagStart];
    UIImageView * imageSeparate = (UIImageView *)[cell viewWithTag:MenuCellTagSeparate];
    [imageStart setHidden:YES];
    if (indexPath.row == 0) {
        labelTitle.text = LocalString(@"DraftBox");
    }
    else if (indexPath.row == 4){
        labelTitle.text = @"设置";
        [imageSeparate setHidden:YES];
    }else {
        if (indexPath.row != 3) {
            [imageSeparate setHidden:YES];
            if (indexPath.row == 1) {
                [imageStart setHidden:NO];
            }
        }
        labelTitle.text = [_rows objectAtIndex:indexPath.row - 1];
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil != _settingViewController) {
        [[AppDelegate delegate].navController popToRootViewControllerAnimated:NO];
        _settingViewController = nil;
    }
    
    if (4 == indexPath.row){
        if (_settingViewController == nil) {
            _settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
        }
        [[AppDelegate delegate].navController pushViewController:_settingViewController animated:NO];
    }else {
        uint types[] = {DataTypeCollectingBox,DataTypeToday, DataTypeRecent, DataTypeHistory};
        if ([AppDelegate delegate].homeViewController.dataType != types[indexPath.row]) {
            [AppDelegate delegate].homeViewController.dataType = types[indexPath.row];
            [[AppDelegate delegate].homeViewController initDataWithAnimation:YES];
        }
    }
    
    [[AppDelegate delegate].homeViewController restoreViewLocation];
}

@end
