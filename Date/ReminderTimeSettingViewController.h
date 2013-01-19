//
//  ReminderTimeSettingViewController.h
//  date
//
//  Created by maoyu on 12-12-26.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderSettingViewController.h"

@interface ReminderTimeSettingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel * labelDay;
@property (weak, nonatomic) IBOutlet UILabel * labelDate;
@property (weak, nonatomic) IBOutlet UILabel * labelTime;
@property (weak, nonatomic) IBOutlet UIButton * btnClear;
@property (weak, nonatomic) IBOutlet UIButton * btnSet;

@property (weak, nonatomic) ReminderSettingViewController * parentContoller;
@property (weak, nonatomic) UIDatePicker * datePick;

- (IBAction)clickClear:(id)sender;
- (IBAction)clickSet:(id)sender;

@end
