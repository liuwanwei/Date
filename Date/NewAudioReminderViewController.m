//
//  NewAudioReminderViewController.m
//  date
//
//  Created by maoyu on 13-1-5.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "NewAudioReminderViewController.h"
#import "AppDelegate.h"
#import "TextEditorViewController.h"

@interface NewAudioReminderViewController ()

@end

@implementation NewAudioReminderViewController

#pragma 私有函数
- (void)initNavBar {
    UIBarButtonItem * leftItem;
    leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:^ {
        [[AppDelegate delegate] checkRemindersExpired];
    }];
}

- (void)saveReminder {
    [self createReminder];
}

- (void)initData {
    self.reminder = [[ReminderManager defaultManager] reminder];
    self.receiverId = [NSNumber numberWithLongLong:[[UserManager defaultManager].oneselfId longLongValue]];
    self.receiver = @"自己";
    SoundManager * manager = [SoundManager defaultSoundManager];
    self.reminder.audioUrl = [manager.recordFileURL relativePath];
    self.reminder.audioLength = [NSNumber numberWithInteger:manager.currentRecordTime];
    self.desc = @"记得做";
}

- (void)updateReceiverCell {
    [self updateTableFooterViewInCreateState];
    [super updateReceiverCell];
}

- (void)updateTriggerTimeCell {
   [self updateTableFooterViewInCreateState];
   [super updateTriggerTimeCell];
}

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

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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

#pragma mark - ReminderManager delegate
- (void)newReminderSuccess:(NSString *)reminderId {
    [super newReminderSuccess:reminderId];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (YES == [self.userManager isOneself:[self.reminder.userID stringValue]] ||
            nil == self.reminder.triggerTime) {
            [[AppDelegate delegate].homeViewController initDataWithAnimation:NO];
            [[AppDelegate delegate] checkRemindersExpired];
        }
        
    }];
}

@end
