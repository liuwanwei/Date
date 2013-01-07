//
//  ShowTextReminderViewController.m
//  date
//
//  Created by lixiaoyu on 13-1-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "ShowTextReminderViewController.h"
#import "AppDelegate.h"

@interface ShowTextReminderViewController ()

@end

@implementation ShowTextReminderViewController

- (void)initData {
    self.receiverId = self.reminder.userID;
    self.triggerTime = self.reminder.triggerTime;
    self.desc = self.reminder.desc;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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
    [self initData];
    [super viewDidLoad];
    [self hiddenTableFooterView];
    self.title = @"查看详情";
    [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
