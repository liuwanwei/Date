//
//  ReminderSendingViewController.h
//  Date
//
//  Created by maoyu on 12-11-20.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"
#import "ReminderManager.h"
#import "ReminderSettingViewController.h"

@interface ReminderSendingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,ReminderManagerDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UITableViewCell * friendCell;

@property (weak, nonatomic) Reminder * reminder;

@property (weak, nonatomic) ReminderSettingViewController * parentController;

@end
