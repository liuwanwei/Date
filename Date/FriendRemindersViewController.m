//
//  FriendRemindersViewController.m
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "FriendRemindersViewController.h"

@interface FriendRemindersViewController () {
}

@end

@implementation FriendRemindersViewController
@synthesize userId = _userId;
@synthesize tableView = _tableView;
@synthesize bilateralFriend = _bilateralFriend;

#pragma 私有函数
- (void)initData {
    self.reminders = [self.reminderManager remindersWithUserId:_userId];
    if (nil != self.reminders) {
        self.remindersAudioState = [NSMutableArray arrayWithCapacity:0];
        NSInteger size = self.reminders.count;
        for (NSInteger index = 0; index < size; index++) {
            [self.remindersAudioState addObject:[NSNumber numberWithInteger:AudioStateNormal]];
        }
        [self.tableView reloadData];
    }
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    self.title = _bilateralFriend.nickname;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    FriendReminderCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FriendReminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    Reminder * reminder = [self.reminders objectAtIndex:indexPath.row];
    cell.indexPath = indexPath;
    if (ReminderTypeSend == [reminder.type integerValue]) {
        cell.bilateralFriend = nil;
    }else {
        cell.bilateralFriend = _bilateralFriend;
    }
    
    cell.reminder = reminder;
    cell.audioState = [[self.remindersAudioState objectAtIndex:indexPath.row] integerValue];
    return cell;
}

@end
