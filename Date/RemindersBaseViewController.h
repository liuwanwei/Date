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

typedef enum {
    ReminderTypeReceive = 0,
    ReminderTypeSend
}ReminderType;

@interface RemindersBaseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,ReminderManagerDelegate,ReminderCellDelegate,SoundManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@property (weak, nonatomic) ReminderManager * reminderManager;
@property (strong, nonatomic) NSArray * reminders;
@property (strong, nonatomic) NSMutableArray * remindersAudioState;

- (NSIndexPath *)indexPathWithReminder:(Reminder *)reminder;

@end
