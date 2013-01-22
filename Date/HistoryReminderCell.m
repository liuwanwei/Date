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
            self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, 26, self.labelDescription.frame.size.width, self.labelDescription.frame.size.height);
        }else {
            [self.labelTriggerDate setHidden:NO];
             self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, 42, self.labelDescription.frame.size.width, self.labelDescription.frame.size.height);
        }
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
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
