//
//  ReminderSettingAudioCell.m
//  date
//
//  Created by maoyu on 12-12-11.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderSettingAudioCell.h"

@implementation ReminderSettingAudioCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReminderSettingAudioCell" owner:self options:nil] ;
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
}

@end
