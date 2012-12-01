//
//  ReminderNotificationDetailViewController.m
//  Date
//
//  Created by maoyu on 12-11-29.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderNotificationViewController.h"
#import "Reminder.h"

@interface ReminderNotificationViewController ()

@end

@implementation ReminderNotificationViewController

@synthesize reminders = _reminders;
@synthesize tableView = _tableView;

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
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    self.tableView.rowHeight = 80.0;
    self.title = @"提醒";
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
    ReminderNotificationCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    /*if (cell == nil) {
        cell = [[FriendReminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    Reminder * reminder = [_reminders objectAtIndex:indexPath.row];
    cell.indexPath = indexPath;
    if (ReminderTypeSend == [reminder.type integerValue]) {
        cell.bilateralFriend = nil;
    }else {
        cell.bilateralFriend = _bilateralFriend;
    }
    
    cell.reminder = reminder;
    cell.audioState = [[_ramindersAudioState objectAtIndex:indexPath.row] integerValue];*/
    return cell;
}


@end
