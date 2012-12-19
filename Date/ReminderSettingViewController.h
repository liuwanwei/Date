//
//  ReminderSettingViewController.h
//  Date
//
//  Created by maoyu on 12-11-19.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChoiceViewController.h"
#import "RemindersBaseViewController.h"
#import "ReminderSettingTimeCell.h"

typedef enum {
    SettingModeNew = 0,
    SettingModeModify
}SettingMode;

@interface ReminderSettingViewController : RemindersBaseViewController <UITableViewDelegate, UITableViewDataSource, ChoiceViewDelegate,ReminderSettingTimeCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;

@property (strong, nonatomic)  Reminder * reminder;
@property (nonatomic) SettingMode settingMode;

@end
