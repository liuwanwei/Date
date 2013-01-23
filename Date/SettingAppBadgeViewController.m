//
//  SettingAppBadgeViewController.m
//  date
//
//  Created by maoyu on 13-1-10.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "SettingAppBadgeViewController.h"
#import "GlobalFunction.h"

@interface SettingAppBadgeViewController (){
    int _selectedIndex;
}

@end

@implementation SettingAppBadgeViewController
@synthesize tableView = _tableView;
@synthesize parentController = _parentController;

#pragma 私有函数
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LocalString(@"SettingAppBadge");
    self.tableView.dataSource= self;
    self.tableView.delegate = self;
    [[GlobalFunction defaultGlobalFunction] initNavleftBarItemWithController:self withAction:@selector(back)];
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
    return [_parentController.appBadgeSignRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_parentController.appBadgeSignRows objectAtIndex:indexPath.row];
    if (_parentController.appBadgeMode == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndex = indexPath.row;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (_selectedIndex != -1 && _selectedIndex != indexPath.row) {
        NSIndexPath * lastIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:indexPath.section];
        UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _selectedIndex = indexPath.row;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _parentController.appBadgeMode = indexPath.row;
    [[ReminderManager defaultManager] storeAppBadgeMode:_parentController.appBadgeMode];
    [_parentController updateAppBadgeCell];
//    [self back];
}

@end
