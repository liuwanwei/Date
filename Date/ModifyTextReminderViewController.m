//
//  ModifyTextReminderViewController.m
//  date
//
//  Created by maoyu on 13-1-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "ModifyTextReminderViewController.h"
#import "AppDelegate.h"
#import "TextEditorViewController.h"
typedef enum {
    TitleTypeShow = 0,
    TitleTypeModify
}TitleType;

@interface ModifyTextReminderViewController ()

@end

@implementation ModifyTextReminderViewController

#pragma 私有函数
- (void)updateTitle:(TitleType)type {
    if (TitleTypeShow == type) {
        self.title = @"提醒详情";
    }else {
        self.title = @"修改提醒";
    }
}

- (void)initData {
    self.receiverId = self.reminder.userID;
    self.triggerTime = self.reminder.triggerTime;
    self.reminderType = [self.reminder.type integerValue];
    self.desc = self.reminder.desc;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveReminder {
    [self modifyReminder];
}

- (void)updateView {
    [self updateTitle:TitleTypeModify];
    [self updateTableFooterView];
}

- (void)updateTableFooterView {
    if (self.tableView.hidden == NO) {
        [self showTabeleFooterView];
    }
    
    if (YES == self.isInbox) {
        [self updateTableFooterViewInModifyInboxState];
    }else {
        [self updateTableFooterViewInModifyAlarmState];
    }
}

- (void)updateReceiverCell {
    [self updateView];
    [super updateReceiverCell];
}

- (void)updateTriggerTimeCell {
    [super updateTriggerTimeCell];
    [self updateView];
}

- (void)updateDescCell {
    [self updateView];
    [super updateDescCell];
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
    [self initData];
    [super viewDidLoad];
    [self updateTitle:TitleTypeShow];
    [self hiddenTableFooterView];
    [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ReminderManager delegate
- (void)newReminderSuccess:(NSString *)reminderId {
    [super newReminderSuccess:reminderId];
    [[AppDelegate delegate].homeViewController initDataWithAnimation:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
