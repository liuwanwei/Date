//
//  HistoryReminderCell.m
//  date
//
//  Created by maoyu on 13-1-18.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "HistoryReminderCell.h"
@interface HistoryReminderCell () {
}

@end


@implementation HistoryReminderCell

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
        self.contentView.backgroundColor  = [UIColor whiteColor];
        self.backgroundView = [[[NSBundle mainBundle] loadNibNamed:@"TodayReminderCellBackgroundView" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

- (void)setReminder:(Reminder *)reminer {
    if (nil != reminer) {
        self.imageViewContactOriX = 120.0;
        [super setReminder:reminer];
        self.oneDay = [self custumDayString:self.reminder.finishedTime];
        
        NSString * date = @"完成于: ";
        if ([@"睡觉前" isEqualToString:self.oneDay]) {
            date = [date stringByAppendingString:@"今天"];
        }else {
            date = [date stringByAppendingString:self.oneDay];
        }
        
        self.labelTriggerDate.text = date;
    }
}

@end
