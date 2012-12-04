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
        self.remindersAudioState = [NSMutableArray arrayWithCapacity:0];
        NSInteger size = self.reminders.count;
        for (NSInteger index = 0; index < size; index++) {
            [self.remindersAudioState addObject:[NSNumber numberWithInteger:AudioStateNormal]];
        }
        
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
        [self.reminderManager modifyReminder:reminder withBellState:NO];
    }
    //[[LMLibrary defaultManager] postNotificationWithName:kRemindesUpdateMessage withObject:nil];
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
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    self.tableView.rowHeight = 100.0;
    self.title = @"到时提醒";
    
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
    static NSString * CellIdentifier = @"Cell";
    ReminderNotificationCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ReminderNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    Reminder * reminder = [self.reminders objectAtIndex:indexPath.row];
    BilateralFriend * friend = [_friends objectForKey:reminder.userID];
    cell.indexPath = indexPath;
    cell.bilateralFriend = friend;
    cell.reminder = reminder;
    if (YES == _isAutoPlayAudio) {
        cell.audioState = AudioStatePlaying;
        [self.remindersAudioState replaceObjectAtIndex:indexPath.row withObject: [NSNumber numberWithInteger:AudioStatePlaying]];
        [cell palyAudio:nil];
    }else {
        cell.audioState = [[self.remindersAudioState objectAtIndex:indexPath.row] integerValue];
    }
    return cell;
}

@end
