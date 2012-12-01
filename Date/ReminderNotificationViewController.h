//
//  ReminderNotificationDetailViewController.h
//  Date
//
//  Created by maoyu on 12-11-29.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderNotificationCell.h"

@interface ReminderNotificationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) NSArray * reminders;
@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end
