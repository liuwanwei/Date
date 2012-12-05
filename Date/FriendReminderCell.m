//
//  FriendReminderCell.m
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "FriendReminderCell.h"

@implementation FriendReminderCell
@synthesize btnClock = _btnClock;
@synthesize btnMark = _btnMark;


#pragma 私有函数
- (void)modifyReminderBellState:(BOOL)isBell {
    [[ReminderManager defaultManager] modifyReminder:self.reminder withBellState:isBell];
    if (YES == [self.reminder.isBell integerValue]) {
        [self.labelTriggerDate setHidden:NO];
        [[ReminderManager defaultManager] addLocalNotificationWithReminder:self.reminder withBilateralFriend:self.bilateralFriend];
    }else {
        [self.labelTriggerDate setHidden:YES];
        [[ReminderManager defaultManager] cancelLocalNotificationWithReminder:self.reminder];
    }
}

#pragma 类成员函数
- (void)modifyReminderReadState{
    if (nil == self.reminder.isRead || NO == [self.reminder.isRead integerValue]) {
        [[ReminderManager defaultManager] modifyReminder:self.reminder withReadState:YES];
        if (YES == [self.reminder.isRead integerValue]) {
            [_btnClock setHidden:NO];
            [_btnMark setHidden:YES];
        }
        [self modifyReminderBellState:YES];
    }
}

#pragma 事件函数
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier reminderType:(ReminderType)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib;
        if (ReminderTypeSend == type) {
             nib = [[NSBundle mainBundle] loadNibNamed:@"FriendReminderSenderCell" owner:self options:nil] ;
        }else {
            nib = [[NSBundle mainBundle] loadNibNamed:@"FriendReminderCell" owner:self options:nil] ;
        }
        self = [nib objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)modifyBell:(UIButton *)sender {
    if (YES == [self.reminder.isBell integerValue]) {
        [self modifyReminderBellState:NO];
    }else {
        [self modifyReminderBellState:YES];
    }
}

- (void)setReminder:(Reminder *)reminer {
    if (nil != reminer) {
        
        [super setReminder:reminer];
        
        if (nil != reminer.isRead && YES == [reminer.isRead integerValue]) {
            [_btnMark setHidden:YES];
        }else {
            [_btnMark setHidden:NO];
        }
    }
}

@end
