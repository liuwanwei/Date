//
//  SettingViewController.m
//  date
//
//  Created by maoyu on 12-12-13.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "SettingViewController.h"
#import "ReminderManager.h"

@interface SettingViewController () {
    NSArray * _appBadgeSignRows;
    AppBadgeMode _appBadgeMode;
}

@end

@implementation SettingViewController
@synthesize tableView = _tableView;

- (void)initMenuView {
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBtnTapped:)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

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
    _appBadgeSignRows = [[NSArray alloc] initWithObjects:@"不显示",@"今日提醒",@"近期提醒", nil];
    self.navigationController.navigationItem.hidesBackButton = YES;
    [self initMenuView];
    _appBadgeMode = [[ReminderManager defaultManager] appBadgeMode];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _appBadgeSignRows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"应用程序标记";
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_appBadgeSignRows objectAtIndex:indexPath.row];
    if (_appBadgeMode == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSIndexPath * path =  [NSIndexPath indexPathForRow:_appBadgeMode inSection:0];
    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:path];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _appBadgeMode = indexPath.row;
    [[ReminderManager defaultManager] storeAppBadgeMode:_appBadgeMode];
}

@end
