//
//  TodayReminderWithTimeCell.m
//  date
//
//  Created by maoyu on 13-1-18.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "TodayReminderCell.h"

@implementation TodayReminderCell

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
}

@end
