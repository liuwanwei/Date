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

@interface ReminderSettingViewController : RemindersBaseViewController <UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource, ChoiceViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;

- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;

- (IBAction)playRecord:(id)sender;
@end
