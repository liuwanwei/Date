//
//  ReminderTimeSettingViewController.h
//  date
//
//  Created by maoyu on 12-12-26.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderSettingViewController.h"

#define kReminderSettingOk          @"ReminderSettingOkMessage"

@interface ReminderTimeSettingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) ReminderSettingViewController * parentContoller;
@property (weak, nonatomic) UIDatePicker * datePick;
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIView * finshView;
@property (nonatomic) int selectedRow;

- (IBAction)clickOK:(id)sender;
- (IBAction)clickCancel:(id)sender;
@end
