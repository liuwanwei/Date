//
//  ReminderNotificationDetailViewController.m
//  Date
//
//  Created by maoyu on 12-11-29.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "RemindersNotificationViewController.h"
#import "Reminder.h"
#import "LMLibrary.h"

@interface RemindersNotificationViewController () {
    NSDictionary * _friends;
    BOOL _isAutoPlayAudio;
}

@end

@implementation RemindersNotificationViewController

#pragma 私有函数
- (void)initData {
    if (nil != self.reminders) {
        NSInteger size = self.reminders.count;
        if (1 == size) {
            _isAutoPlayAudio = YES;
        }
        
        NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
        for (Reminder * reminder in self.reminders) {
            [array addObject:reminder.userID];
        }
            
        _friends = [[BilateralFriendManager defaultManager] friendsWithId:array];
        if (nil != _friends) {
            [self.tableView reloadData];
        }
    }
}

- (void)dismiss {
    for (Reminder * reminder in self.reminders) {
        [self.reminderManager modifyReminder:reminder withBellState:YES];
    }
  
    [self dismissViewControllerAnimated:YES completion:nil];
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
    // Do any additional setup after loading the view from its nib.
    self.title = @"提醒";
    
    _isAutoPlayAudio = NO;
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reminders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Reminder * reminder = [self.reminders objectAtIndex:indexPath.row];
    static NSString * CellIdentifier = @"ReminderNotificationCell";
    ReminderNotificationCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ReminderNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    
    BilateralFriend * friend = [_friends objectForKey:reminder.userID];
    cell.indexPath = indexPath;
    cell.bilateralFriend = friend;
    cell.reminder = reminder;
    if (YES == _isAutoPlayAudio) {
        cell.audioState = AudioStatePlaying;
        [cell palyAudio:cell.btnAudio];
    }else {
        cell.audioState = AudioStateNormal;
    }
    return cell;
}

@end
