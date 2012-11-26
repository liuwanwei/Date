//
//  ReminderSendingViewController.m
//  Date
//
//  Created by maoyu on 12-11-20.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderSendingViewController.h"
#import "BilateralFriendManager.h"
#import "EGOImageView.h"
#import "BilateralFriend.h"
#import "MBProgressManager.h"

@interface ReminderSendingViewController () {
    NSArray * _friends;
    NSInteger _selectedRow;
    ReminderManager * _reminderManager;
}

@end

@implementation ReminderSendingViewController
@synthesize tableView = _tableView;
@synthesize friendCell = _friendCell;
@synthesize reminder = _reminder;

#pragma 私有函数
- (void)initData {
    _friends = [[BilateralFriendManager defaultManager] allOnlineFriends];
    if (nil != _friends) {
        [self.tableView reloadData];
    }
}

- (void)sendReminder {
    if (_reminder.userID != nil) {
         _reminderManager.delegate = self;
        [_reminderManager sendReminder:_reminder];
        [[MBProgressManager defaultManager] showHUD:@"发送中"];
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
    _reminderManager = [ReminderManager defaultManager];
    _selectedRow = -1;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60.0;
    NSLog(@"%@", [EGOImageView class]);
    [self initData];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendReminder)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    EGOImageView * imageView;
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"OnlineFriendRemindCell" owner:self options:nil];
        cell = _friendCell;
        self.friendCell = nil;
        
        imageView = (EGOImageView *)[cell viewWithTag:1];
        [imageView  setPlaceholderImage:[UIImage imageNamed:@"male"]];
    } else {
        imageView = (EGOImageView *)[cell viewWithTag:1];
    }
    
    BilateralFriend * friend = [_friends objectAtIndex:indexPath.row];
    if (nil != friend.imageUrl) {
        [imageView setImageURL:[NSURL URLWithString:friend.imageUrl]];
    }
    
    UILabel * nicknameLabel = (UILabel *)[cell viewWithTag:2];
    nicknameLabel.text = friend.nickname;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (_selectedRow != -1) {
        NSIndexPath * path =  [NSIndexPath indexPathForRow:_selectedRow inSection:0];
        UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:path];
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _selectedRow = indexPath.row;
    BilateralFriend * friend = [_friends objectAtIndex:indexPath.row];
    
    _reminder.userID = friend.userID;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - ReminderManager delegate
- (void)newReminderSuccess {
    [[MBProgressManager defaultManager] removeHUD];
    _reminderManager.delegate = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)newReminderFailed {
    
}


@end
