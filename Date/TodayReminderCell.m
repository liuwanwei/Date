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
            if ([@"" isEqualToString:day]) {
                self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, 26, self.labelDescription.frame.size.width, self.labelDescription.frame.size.height);
            }else {
                self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, 42, self.labelDescription.frame.size.width, self.labelDescription.frame.size.height);
            }
            
        }else {
            [self.labelTriggerDate setHidden:NO];
            self.labelDay.frame = CGRectMake(LabelDayOriX,self.labelDay.frame.origin.y, self.labelDay.frame.size.width, self.labelDay.frame.size.height);
            self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, 42, self.labelDescription.frame.size.width, self.labelDescription.frame.size.height);
        }

        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
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

- (void)setReminder:(Reminder *)reminder {
     [super setReminder:reminder];
     [self setDateTimeView];
    
}

@end
