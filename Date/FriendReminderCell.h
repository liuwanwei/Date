//
//  FriendReminderCell.h
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderBaseCell.h"

@interface FriendReminderCell : ReminderBaseCell

@property (weak, nonatomic) IBOutlet UIButton * btnClock;
@property (weak, nonatomic) IBOutlet UIButton * btnMark;

- (IBAction)modifyBell:(UIButton *)sender;

- (void)modifyReminderReadState;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier reminderType:(ReminderType)type;
@end
