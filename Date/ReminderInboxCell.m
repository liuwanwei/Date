//
//  ReminderInboxCell.m
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderInboxCell.h"

@implementation ReminderInboxCell
@synthesize btnMark = _btnMark;
@synthesize labelBellSign = _labelBellSign;

#pragma 类成员函数
- (void)modifyReminderReadState{
    if (nil == self.reminder.isRead || NO == [self.reminder.isRead integerValue]) {
        [[ReminderManager defaultManager] modifyReminder:self.reminder withReadState:YES];
        if (YES == [self.reminder.isRead boolValue]) {
            [_btnMark setHidden:YES];
        }
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReminderInboxCell" owner:self options:nil] ;
        self = [nib objectAtIndex:0];
        self.contentView.backgroundColor  = [UIColor whiteColor];
        self.backgroundView = [[[NSBundle mainBundle] loadNibNamed:@"TodayReminderCellBackgroundView" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

- (void)setReminder:(Reminder *)reminer {
    [super setReminder:reminer];
    self.oneDay = [self custumDayString:self.reminder.createTime];

    NSString * date = @"创建于: ";
    if ([@"睡觉前" isEqualToString:self.oneDay]) {
       date = [date stringByAppendingString:@"今天"];
    }else {
       date = [date stringByAppendingString:self.oneDay];
    }
    
    self.labelTriggerDate.text = date;
}

@end
