//
//  ReminderSettingTimeCell.h
//  date
//
//  Created by maoyu on 12-12-14.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReminderSettingTimeCellDelegate <NSObject>

@optional
- (void)valueChangedWithSwitch:(UISwitch *)sender;
@end

@interface ReminderSettingTimeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * labelTitle;
@property (weak, nonatomic) IBOutlet UISwitch * switchTime;
@property (weak, nonatomic) IBOutlet UILabel * labelTriggerTime;

@property (weak, nonatomic) id<ReminderSettingTimeCellDelegate> delegate;
@property (weak, nonatomic) NSDate * triggerTime;

- (IBAction)valueChanged:(UISwitch *)sender;
@end
