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
#import "RemindersBaseViewController.h"

typedef  enum {
    DeailViewShowModePush = 0,
    DeailViewShowModePresent = 1
}DeailViewShowMode;

@interface ReminderDetailViewController : RemindersBaseViewController
@property (strong, nonatomic) Reminder * reminder;
@property (strong, nonatomic) BilateralFriend * friend;
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) NSInteger detailViewShowMode;
@property (strong, nonatomic) NSArray * sections;
@property (strong, nonatomic)  NSDateFormatter * dateFormatter;

@end
