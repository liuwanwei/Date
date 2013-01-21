//
//  TodayReminderWithTimeCell.m
//  date
//
//  Created by maoyu on 13-1-18.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#define LabelDayOriX    100

#import "TodayReminderCell.h"

@implementation TodayReminderCell


- (void)setDateTimeView {
    if (nil != self.reminder.triggerTime) {
        NSString * day = @"";
        if (DataTypeRecent == self.dateType) {
            [self.labelDay setHidden:YES];
        }else {
            [self.labelDay setHidden:NO];
            day = [self custumDayString:self.reminder.triggerTime];
        }
        
        if (ReminderTypeReceiveAndNoAlarm == [self.reminder.type integerValue]) {
            [self.labelTriggerDate setHidden:YES];
            self.labelDay.frame = CGRectMake(self.labelTriggerDate.frame.origin.x,self.labelDay.frame.origin.y, self.labelDay.frame.size.width, self.labelDay.frame.size.height);
        }else {
            [self.labelTriggerDate setHidden:NO];
            self.labelDay.frame = CGRectMake(LabelDayOriX,self.labelDay.frame.origin.y, self.labelDay.frame.size.width, self.labelDay.frame.size.height);
        }
    
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
    
        if (YES == [self.reminder.isAlarm boolValue]) {
            self.labelTriggerDate.textColor = RGBColor(153,153,153);
//            self.labelTriggerDate.font = [UIFont systemFontOfSize:20.0];
        }else {
            self.labelTriggerDate.textColor = RGBColor(0,0,0);
//            self.labelTriggerDate.font = [UIFont systemFontOfSize:20.0];
        }
        self.labelTriggerDate.text =[formatter stringFromDate:self.reminder.triggerTime];
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
    }
    return self;
}

- (void)setReminder:(Reminder *)reminer {
    if (nil != reminer) {
        [super setReminder:reminer];
        [self setDateTimeView];
    }
}

@end
