//
//  TodayReminderWithTimeCell.m
//  date
//
//  Created by maoyu on 13-1-18.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "TodayReminderCell.h"

@implementation TodayReminderCell

#pragma 事件函数
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"TodayReminderCell" owner:self options:nil] ;
        self = [nib objectAtIndex:0];
        self.contentView.backgroundColor  = [UIColor whiteColor];
    }
    return self;
}

- (void)setReminder:(Reminder *)reminder {
    self.imageViewContactOriX = 83.0;
    [super setReminder:reminder];
    
    self.oneDay = [self custumDayString:self.reminder.triggerTime];

    if (ReminderTypeReceiveAndNoAlarm == [reminder.type integerValue]) {
        if ([@"睡觉前" isEqualToString:self.oneDay]) {
            [self.labelTriggerDate setHidden:NO];
            [self.labelDay setHidden:YES];
            self.labelTriggerDate.text = self.oneDay;
        }
    }else {
        if ([@"睡觉前" isEqualToString:self.oneDay]) {
            [self.labelTriggerDate setHidden:NO];
            [self.labelDay setHidden:YES];
            self.labelTriggerDate.text = self.triggerTime;
        }
    }
    
    if (![@"睡觉前" isEqualToString:self.oneDay]) {
        [self.labelTriggerDate setHidden:YES];
        [self.labelDay setHidden:NO];
        self.labelDay.text = self.oneDay;

    }
}

@end
