//
//  TodayReminderWithTimeCell.m
//  date
//
//  Created by maoyu on 13-1-18.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "TodayReminderCell.h"

@implementation TodayReminderCell


- (void)setDateTimeView {
    if (nil != self.reminder.triggerTime) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString * triggerTime = [formatter stringFromDate:self.reminder.triggerTime];

        NSString * day = @"";
        if (DataTypeRecent == self.dateType) {
            [self.labelDay setHidden:YES];
        }else {
            [self.labelDay setHidden:NO];
            day = [self custumDayString:self.reminder.triggerTime];
        }
        
        if (ReminderTypeReceiveAndNoAlarm == [self.reminder.type integerValue]) {
            [self.labelTriggerDate setHidden:YES];
            [self.labelNickname setHidden:YES];
        }else {
            if ([@"" isEqualToString:day]) {
                [self.labelTriggerDate setHidden:NO];
                [self.labelDay setHidden:YES];
                self.labelTriggerDate.text = triggerTime;
                self.labelNickname.frame = CGRectMake(kNickNameLabelChangedX, self.labelNickname.frame.origin.y, self.labelNickname.frame.size.width, self.labelNickname.frame.size.height);
            }else {
                [self.labelTriggerDate setHidden:YES];
                [self.labelDay setHidden:NO];
                self.labelNickname.frame = CGRectMake(kNickNameLabelOriX, self.labelNickname.frame.origin.y, self.labelNickname.frame.size.width, self.labelNickname.frame.size.height);
            }
            [self showFrom];
        }

        self.labelDay.text = day;
    }
}

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
        self.backgroundView = [[[NSBundle mainBundle] loadNibNamed:@"TodayReminderCellBackgroundView" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

- (void)setReminder:(Reminder *)reminder {
    self.labelDescOriwidth = 220;
     [super setReminder:reminder];
     [self setDateTimeView];
    
}

@end
