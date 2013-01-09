//
//  ReminderSettingViewController.h
//  Date
//
//  Created by maoyu on 12-11-19.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomChoiceViewController.h"
#import "RemindersBaseViewController.h"
#import "ReminderSettingTimeCell.h"
#import "MBProgressManager.h"
#import "RemindersInboxViewController.h"

@interface ReminderSettingViewController : RemindersBaseViewController <UITableViewDelegate, UITableViewDataSource,ReminderManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;

@property (strong, nonatomic) Reminder * reminder;
@property (strong, nonatomic) NSString * desc;
@property (weak, nonatomic) NSString * receiver;
@property (strong, nonatomic) NSNumber * receiverId;
@property (strong, nonatomic) NSDate * triggerTime;
@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isAuthValid;
@property (weak, nonatomic) UserManager * userManager;
@property (nonatomic) BOOL isInbox;
@property (nonatomic) CGSize labelSize;

- (void)updateReceiverCell;
- (void)updateTriggerTimeCell;
- (void)updateDescCell;
- (NSString *)stringTriggerTime;
- (void)clickTrigeerTimeRow:(NSIndexPath *)indexPath;
- (void)clickSendRow;
- (void)initTableFooterView;
- (void)updateTableFooterViewInCreateState;
- (void)updateTableFooterViewInModifyInboxState;
- (void)updateTableFooterViewInModifyAlarmState;
- (void)hiddenTableFooterView;
- (void)showTabeleFooterView;
- (void)createReminder;
- (void)modifyReminder;
- (void)computeFontSize;
@end
