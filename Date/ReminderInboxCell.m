//
//  ReminderInboxCell.m
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderInboxCell.h"
#import "LMLibrary.h"

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
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setReminder:(Reminder *)reminer {
    if (nil != reminer) {
        
        [super setReminder:reminer];
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        self.labelSendDate.text = [formatter stringFromDate:reminer.createTime];
        
        if (nil != reminer.isRead && YES == [reminer.isRead integerValue]) {
            [_btnMark setHidden:YES];
            [self.btnFinished setHidden:NO];
        }else {
            [_btnMark setHidden:NO];
            [self.btnFinished setHidden:YES];
        }
        
        if (ReminderStateFinish == [reminer.state integerValue]) {
            self.labelTriggerDate.textColor = RGBColor(153,153,153);
            self.labelTriggerDate.font = [UIFont systemFontOfSize:14.0];
            [self.btnFinished setBackgroundImage:[UIImage imageNamed:@"checkboxCompleted"] forState:UIControlStateNormal];
        }else{
            self.labelTriggerDate.textColor = RGBColor(0,0,0);
            self.labelTriggerDate.font = [UIFont boldSystemFontOfSize:14.0];
            [self.btnFinished setBackgroundImage:[UIImage imageNamed:@"checkboxOri"] forState:UIControlStateNormal];
        }
//        if (YES == [reminer.isBell boolValue]) {
//            [_labelBellSign setHidden:NO];
//        }else {
//            [_labelBellSign setHidden:YES];
//        }
    }
}

@end
