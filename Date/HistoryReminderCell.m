//
//  HistoryReminderCell.m
//  date
//
//  Created by maoyu on 13-1-18.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "HistoryReminderCell.h"

@implementation HistoryReminderCell

- (void)setDateTimeView {
    if (nil != self.reminder.triggerTime) {
        if (ReminderTypeReceiveAndNoAlarm == [self.reminder.type integerValue]) {
            [self.labelTriggerDate setHidden:YES];
        }else {
            [self.labelTriggerDate setHidden:NO];
        }
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        if (YES == [self.reminder.isAlarm boolValue]) {
            self.labelTriggerDate.textColor = RGBColor(153,153,153);
            self.labelTriggerDate.font = [UIFont systemFontOfSize:20.0];
        }else {
            self.labelTriggerDate.textColor = RGBColor(0,0,0);
            self.labelTriggerDate.font = [UIFont systemFontOfSize:20.0];
        }
        self.labelTriggerDate.text =[formatter stringFromDate:self.reminder.triggerTime];
    }else {
        [self.labelTriggerDate setHidden:YES];
    }
}

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
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryReminderCell" owner:self options:nil] ;
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
