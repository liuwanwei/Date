//
//  TodayRemindersViewController.m
//  date
//
//  Created by maoyu on 13-1-18.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "TodayRemindersViewController.h"

@interface TodayRemindersViewController ()

@end

@implementation TodayRemindersViewController

#pragma 私有函数
- (void)initDataWithAnimation:(BOOL)animation {
    self.reminders = [self.reminderManager todayUnFinishedReminders];
    [self.tableView reloadData];
    
    if (nil != self.reminders) {
        [self.labelPrompt setHidden:YES];
        if (YES == animation) {
            [self.tableView beginUpdates];
        }
        self.usersIdArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (Reminder * reminder in self.reminders) {
            [self addUserId:reminder.userID];
        }
        self.friends = [[BilateralFriendManager defaultManager] friendsWithId:self.usersIdArray];
        if (YES == animation) {
            [self.tableView endUpdates];
        }
        
    }else {
        [self.labelPrompt setHidden:NO];
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
    self.title = @"今日提醒";
    [self addRefreshHeaderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
