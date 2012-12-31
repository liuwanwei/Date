//
//  RemindersBaseViewController.h
//  date
//
//  Created by maoyu on 12-12-1.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderManager.h"
#import "ReminderBaseCell.h"
#import "SoundManager.h"
#import "ReminderMapViewController.h"
#import "BaseViewController.h"

@interface RemindersBaseViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource,ReminderManagerDelegate,ReminderCellDelegate,SoundManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@property (weak, nonatomic) ReminderManager * reminderManager;
@property (weak, nonatomic) NSArray * reminders;
@property (weak, nonatomic) Reminder * curReminder;
@property (strong, nonatomic) NSIndexPath * curIndexPath;
@property (strong, nonatomic) NSMutableDictionary * group;
@property (strong, nonatomic) NSMutableArray * keys;

- (NSString *)custumDateString:(NSString *)date withShowDate:(BOOL)show;
- (NSString *)custumDayString:(NSDate *)date;
- (NSString *)custumDateTimeString:(NSDate *)date;
@end
