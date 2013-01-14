//
//  NewTextReminderViewController.m
//  date
//
//  Created by maoyu on 13-1-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "NewTextReminderViewController.h"
#import "AppDelegate.h"
#import "TextEditorViewController.h"

@interface NewTextReminderViewController ()

@end

@implementation NewTextReminderViewController

#pragma 私有函数
- (void)initNavBar {
    UIBarButtonItem * leftItem;
    leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:^ {
        //[[AppDelegate delegate] checkRemindersExpired];
    }];
}

- (void)saveReminder {
    [self createReminder];
}

- (void)initData {
    self.reminder = [[ReminderManager defaultManager] reminder];
    self.receiverId = [NSNumber numberWithLongLong:[[UserManager defaultManager].oneselfId longLongValue]];
    self.receiver = @"自己";
    [self initTriggerTime];
}

- (void)updateReceiverCell {
    [self updateTableFooterViewInCreateState];
    [super updateReceiverCell];
}

- (void)updateTriggerTimeCell {
    [self updateTableFooterViewInCreateState];
    [super updateTriggerTimeCell];
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
    self.title = @"新建提醒";
    [self initNavBar];
    [self initData];
    [self updateTableFooterViewInCreateState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ReminderManager delegate
- (void)newReminderSuccess:(NSString *)reminderId {
    [super newReminderSuccess:reminderId];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (YES == [self.userManager isOneself:[self.reminder.userID stringValue]] ||
            nil == self.reminder.triggerTime) {
            [[AppDelegate delegate].homeViewController initDataWithAnimation:NO];
            //[[AppDelegate delegate] checkRemindersExpired];
        }
        
    }];
}

@end
