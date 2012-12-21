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
@property (strong, nonatomic) NSArray * reminders;
@property (weak, nonatomic) Reminder * curReminder;
@property (strong, nonatomic) NSIndexPath * curIndexPath;

- (NSString *)custumDateString:(NSString *)date;

@end
