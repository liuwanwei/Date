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

typedef enum {
    SettingModeNew = 0,
    SettingModeModify = 1,
    SettingModeShow
}SettingMode;

@interface ReminderSettingViewController : RemindersBaseViewController <UITableViewDelegate, UITableViewDataSource, ChoiceViewDelegate,ReminderSettingTimeCellDelegate,ReminderManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;

@property (strong, nonatomic) Reminder * reminder;
@property (strong, nonatomic) NSString * desc;
@property (nonatomic) SettingMode settingMode;
@property (weak, nonatomic) NSString * receiver;
@property (strong, nonatomic) NSNumber * receiverId;
@property (strong, nonatomic) NSDate * triggerTime;
@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isAuthValid;
@property (nonatomic) BOOL isSpread;

- (void)updateReceiverCell;
- (void)updateTriggerTimeCell;
- (void)updateDescCell;
- (void)initData;
- (NSString *)stringTriggerTime;
- (void)clickTrigeerTimeRow:(NSIndexPath *)indexPath;
- (void)clickSendRow;
@end
