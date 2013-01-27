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
//        [self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellBg"]]];

    }
    return self;
}

- (void)setReminder:(Reminder *)reminer {
    if (nil != reminer) {
        [super setReminder:reminer];
    }
}

@end
