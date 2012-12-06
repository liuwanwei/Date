//
//  ReminderDetailViewController.h
//  date
//
//  Created by maoyu on 12-12-6.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"
#import "BilateralFriend.h"

@interface ReminderDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Reminder * reminder;
@property (strong, nonatomic) BilateralFriend * friend;
@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end
