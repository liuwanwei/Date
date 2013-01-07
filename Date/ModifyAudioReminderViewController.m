//
//  ModifyAudioReminderViewController.m
//  date
//
//  Created by maoyu on 13-1-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "ModifyAudioReminderViewController.h"
#import "AppDelegate.h"
#import "TextEditorViewController.h"

typedef enum {
    TitleTypeShow = 0,
    TitleTypeModify
}TitleType;

@interface ModifyAudioReminderViewController ()

@end

@implementation ModifyAudioReminderViewController

#pragma 私有函数
- (void)initData {
    self.receiverId = self.reminder.userID;
    self.triggerTime = self.reminder.triggerTime;
    self.desc = self.reminder.desc;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveReminder {
    [self modifyReminder];
}

- (void)updateTitle:(TitleType)type {
    if (TitleTypeShow == type) {
        self.title = @"提醒详情";
    }else {
        self.title = @"修改提醒";
    }
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
    [self updateView];
    [super updateTriggerTimeCell];
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
    [super viewDidLoad];
    [self updateTitle:TitleTypeShow];
    [self hiddenTableFooterView];
    [self initData];
    [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

#pragma mark - ReminderManager delegate
- (void)newReminderSuccess:(NSString *)reminderId {
    [super newReminderSuccess:reminderId];
    
    [[AppDelegate delegate].homeViewController initDataWithAnimation:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        TextEditorViewController * editor = [[TextEditorViewController alloc] initWithStyle:UITableViewStyleGrouped];
        editor.text = self.desc;
        editor.parentController = self;
        
        [self.navigationController pushViewController:editor animated:YES];
    }else if (indexPath.row == 2) {
        [self clickTrigeerTimeRow:indexPath];
    }else if (indexPath.row == 3 && YES == self.isLogin) {
        [self clickSendRow];
    }
}


@end
