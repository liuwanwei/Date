//
//  ReminderTimeSettingViewController.h
//  date
//
//  Created by maoyu on 12-12-26.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderSettingViewController.h"

@interface ReminderTimeSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;

@property (weak, nonatomic) ReminderSettingViewController * parentContoller;

@end
