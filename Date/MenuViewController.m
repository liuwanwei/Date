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
#import "AboutUsViewController.h"
#import "SettingViewController.h"

typedef enum {
    MenuCellTagTitle = 1,
    MenuCellTagStar,
    MenuCellTagSeparator,
    MenuCellTagCount
}MenuCellTag;

@interface MenuViewController () {
    ServerMode _serverMode;
    NSArray * _rows;
    NSArray * _rowImages;
    SettingViewController * _settingViewController;
    AboutUsViewController * _aboutUsViewController;
    LoginViewController * _loginViewController;
}

@end

@implementation MenuViewController
@synthesize btnServerMode = _btnServerMode;
@synthesize tableView = _tableView;
@synthesize menuCell = _menuCell;
@synthesize lastIndexPath = _lastIndexPath;

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
    _rows = [[NSArray alloc] initWithObjects:kTodayReminder,kFutureReminder,kFinishedReminder, nil];
    _rowImages = [[NSArray alloc] initWithObjects:@"today", @"recently", @"history", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.rowHeight = 50.0;
    _lastIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView selectRowAtIndexPath:_lastIndexPath animated:NO scrollPosition:0];

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

- (IBAction)settingButtonClicked:(id)sender{
    SettingViewController * settingsVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    [[GlobalFunction defaultInstance] customizeNavigationBar:nav.navigationBar];
    UIViewController * controller = [[[AppDelegate delegate] window] rootViewController];
    [controller presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"MenuCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
        cell = self.menuCell;
        _menuCell = nil;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
    }

    UILabel * labelTitle = (UILabel *)[cell viewWithTag:MenuCellTagTitle];
//    labelTitle.textColor = RGBColor(255, 255, 255);
    UIImageView * imageStart = (UIImageView *)[cell viewWithTag:MenuCellTagStar];
    UIImageView * imageSeparate = (UIImageView *)[cell viewWithTag:MenuCellTagSeparator];
    [imageStart setHidden:YES];
    UILabel * labelCount = (UILabel *)[cell viewWithTag:MenuCellTagCount];
    
    ReminderManager * reminderManager = [ReminderManager defaultManager];
    NSString * remindersSize;
    if (indexPath.row == 0) {
        remindersSize = [NSString stringWithFormat:@"%d", reminderManager.draftRemindersSize];
        labelTitle.text = LocalString(@"DraftBox");
        labelCount.text = remindersSize;
    }
    else if (indexPath.row == 4){
        labelTitle.text = @"设置";
        [imageSeparate setHidden:YES];
        [labelCount setHidden:YES];
    }else {
        labelTitle.text = [_rows objectAtIndex:indexPath.row - 1];
            if (indexPath.row == 1) {
                remindersSize = [NSString stringWithFormat:@"%d", reminderManager.todayRemindersSize];
                labelCount.text = remindersSize;
                [imageSeparate setHidden:YES];
            }else if(indexPath.row == 2) {
                remindersSize = [NSString stringWithFormat:@"%d", reminderManager.futureRemindersSize];
                labelCount.text = remindersSize;
            }else if (indexPath.row == 3) {
                // TODO 计算已完成比较耗时，可精简。
                remindersSize = [NSString stringWithFormat:@"%d",
                                 reminderManager.historyReminders.count];
                labelCount.text = remindersSize;
            }
    }
    
    if (_lastIndexPath.section == indexPath.section && _lastIndexPath.row == indexPath.row) {
        if (_lastIndexPath.row == 0 || _lastIndexPath.row == 2 || _lastIndexPath.row == 3) {
            [imageSeparate setHidden:YES];
        }
        [self.tableView selectRowAtIndexPath:_lastIndexPath animated:NO scrollPosition:0];
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
    
    if (nil != _aboutUsViewController) {
        [[AppDelegate delegate].navController popToRootViewControllerAnimated:NO];
        _settingViewController = nil;
    }
    
    UITableViewCell * cell;;
    UIImageView * imageSeparate;
    
    cell = [tableView cellForRowAtIndexPath:_lastIndexPath];
    imageSeparate = (UIImageView *)[cell viewWithTag:MenuCellTagSeparator];
    
    cell = [tableView cellForRowAtIndexPath:indexPath];
    imageSeparate = (UIImageView *)[cell viewWithTag:MenuCellTagSeparator];
    if (0 == indexPath.row || 2 == indexPath.row) {
        [imageSeparate setHidden:YES];
    }
    
    _lastIndexPath = indexPath;
    
    uint types[] = {DataTypeCollectingBox,DataTypeToday, DataTypeRecent, DataTypeHistory};
    if ([AppDelegate delegate].homeViewController.dataType != types[indexPath.row]) {
        [AppDelegate delegate].homeViewController.dataType = types[indexPath.row];
        [[AppDelegate delegate].homeViewController initDataWithAnimation:YES];
    }
    
    [[AppDelegate delegate].homeViewController restoreViewLocation];
}

@end
