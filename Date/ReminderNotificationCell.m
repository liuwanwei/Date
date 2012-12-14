//
//  ReminderNotificationCell.m
//  date
//
//  Created by maoyu on 12-12-1.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderNotificationCell.h"

@implementation ReminderNotificationCell
@synthesize btnMark = _btnMark;

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
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReminderNotificationCell" owner:self options:nil] ;
        self = [nib objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setReminder:(Reminder *)reminder {
    if (nil != reminder) {
        [super setReminder:reminder];
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM HH:mm"];
    self.labelSendDate.text = [formatter stringFromDate:reminder.createTime];
    
    if (nil != reminder.isRead && YES == [reminder.isRead integerValue]) {
        [_btnMark setHidden:YES];
    }else {
        [_btnMark setHidden:NO];
    }
}

@end
