//
//  RemindersInboxViewController.m
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "RemindersInboxViewController.h"
#import "ReminderInboxCell.h"

@interface RemindersInboxViewController () {
    NSMutableDictionary * _group;
    NSMutableArray * _keys;
    NSMutableArray * _usersIdArray;
    NSMutableDictionary * _usersIdDictionary;
    NSDictionary * _friends;
}

@end

@implementation RemindersInboxViewController

#pragma 私有函数
- (void)addUserId:(NSNumber *)userId {
    if (nil == [_usersIdDictionary objectForKey:[userId stringValue]]) {
        [_usersIdDictionary setValue:userId forKey:[userId stringValue]];
        [_usersIdArray addObject:userId];
    }
}

- (void)initData {
    self.reminders = [self.reminderManager allRemindersWithReimnderType:ReminderTypeReceive];
    if (nil != self.reminders) {
        _group = [[NSMutableDictionary alloc] initWithCapacity:0];
        _keys = [[NSMutableArray alloc] initWithCapacity:0];
        _usersIdArray = [[NSMutableArray alloc] initWithCapacity:0];
        _usersIdDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yy-MM-dd"];
        NSMutableArray * reminders;
        NSString * key;
        for (Reminder * reminder in self.reminders) {
            key = [formatter stringFromDate:reminder.sendTime];
            // FIXME key怎么会有nil？
            if (nil != key) {
                if (nil == [_group objectForKey:key]) {
                    reminders = [[NSMutableArray alloc] init];
                    [reminders addObject:reminder];
                    [_group setValue:reminders forKey:key];
                    [_keys addObject:key];
                }else {
                    [reminders addObject:reminder];
                }
                
                [self addUserId:reminder.userID];
            }
        }
        _friends = [[BilateralFriendManager defaultManager] friendsWithId:_usersIdArray];
        [self.tableView reloadData];
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
    // Do any additional setup after loading the view from its nib.
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
    if (nil != _group) {
        return [_group count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_keys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * reminders = [_group objectForKey:[_keys objectAtIndex:section]];
    if (nil != reminders) {
        return [reminders count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Reminder * reminder = [self.reminders objectAtIndex:indexPath.row];
    static NSString * CellIdentifier = @"ReminderInboxCell";
    ReminderInboxCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ReminderInboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        NSLog(@"aa");
    }
    
    BilateralFriend * friend = [_friends objectForKey:reminder.userID];
    cell.indexPath = indexPath;
    cell.bilateralFriend = friend;
    cell.reminder = reminder;
    cell.audioState = AudioStateNormal;
    return cell;
}

@end
