//
//  FriendRemindersViewController.m
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "FriendRemindersViewController.h"
#import "ReminderManager.h"
#import "FriendReminderCell.h"

@interface FriendRemindersViewController () {
    NSArray * _reminders;
    NSMutableArray * _audioState;
    ReminderManager * _reminderManager;
}

@end

@implementation FriendRemindersViewController
@synthesize userId = _userId;
@synthesize tableView = _tableView;

#pragma 私有函数
- (void)initData {
    _reminders = [_reminderManager remindersWithUserId:_userId];
    if (nil != _reminders) {
        _audioState = [NSMutableArray arrayWithCapacity:0];
        NSInteger size = _reminders.count;
        for (NSInteger index = 0; index < size; index++) {
            [_audioState addObject:[NSNumber numberWithInteger:AudioStateNormal]];
        }
        [self.tableView reloadData];
    }
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _reminderManager = [ReminderManager defaultManager];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _reminders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    FriendReminderCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FriendReminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.reminer = [_reminders objectAtIndex:indexPath.row];
    return cell;
}

@end
