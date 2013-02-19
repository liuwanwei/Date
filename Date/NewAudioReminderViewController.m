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
#import "MobClick.h"

@interface NewAudioReminderViewController ()

@end

@implementation NewAudioReminderViewController

#pragma 私有函数
- (void)dismiss {
    [[SoundManager defaultSoundManager] deleteAudioFile:self.reminder.audioUrl];
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
    SoundManager * manager = [SoundManager defaultSoundManager];
    self.reminder.audioUrl = [manager.recordFileURL relativePath];
    self.reminder.audioLength = [NSNumber numberWithInteger:manager.currentRecordTime];
    self.desc = @"记得做";
    self.reminderType = ReminderTypeReceiveAndNoAlarm;
    [self initTriggerTime];
}

- (void)updateReceiverCell {
    [self updateTableFooterViewInCreateState];
    [super updateReceiverCell];
}

- (void)updateTriggerTimeCell {
    [super updateTriggerTimeCell];
    [self updateTableFooterViewInCreateState];
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
    self.title = @"新建提醒";
    
    UIBarButtonItem * leftItem;
    leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    [[GlobalFunction defaultGlobalFunction] customNavigationBarItem:leftItem];
    self.navigationItem.leftBarButtonItem = leftItem;
    
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
    NSString * type;
    NSString * target;
    NSString * date;
    NSString * event = kUMengEventReminderCreate;

    if (nil == self.reminder.triggerTime) {
        target = kUMengEventReminderParamSelf;
        type = kUMengEventReminderParamNoAlarm;
        date = kUMengEventReminderParamCollectingBox;
        [AppDelegate delegate].homeViewController.dataType = DataTypeCollectingBox;
    }else {
        if (YES == [self.userManager isOneself:[self.reminder.userID stringValue]]) {
            target = kUMengEventReminderParamSelf;
        }else {
            target = kUMengEventReminderParamOthers;
        }
        
        if (ReminderTypeReceiveAndNoAlarm == [self.reminder.type integerValue]) {
            type = kUMengEventReminderParamNoAlarm;
        }else {
            type = kUMengEventReminderParamAlarm;
        }
        NSDate * tommrow = [[GlobalFunction defaultGlobalFunction] tomorrow];
        if ([self.reminder.triggerTime compare:tommrow] == NSOrderedAscending) {
            date = kUMengEventReminderParamToady;
            [AppDelegate delegate].homeViewController.dataType = DataTypeToday;
        }else {
            date = kUMengEventReminderParamOtherDay;
            [AppDelegate delegate].homeViewController.dataType = DataTypeRecent;
        }
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date,kUMengEventReminderParamDate,type, kUMengEventReminderParamType, target, kUMengEventReminderParamTarget, nil];
    [MobClick event:event attributes:dict];
    
    [[AppDelegate delegate].homeViewController initDataWithAnimation:NO];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
