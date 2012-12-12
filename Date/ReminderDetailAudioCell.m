//
//  ReminderDetailAudioCell.m
//  date
//
//  Created by maoyu on 12-12-10.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderDetailAudioCell.h"

@implementation ReminderDetailAudioCell
@synthesize labelDesc = _labelDesc;
@synthesize labelTitle = _labelTitle;

- (void)modifyReminderReadState{
    if (nil == self.reminder.isRead || NO == [self.reminder.isRead integerValue]) {
        [[ReminderManager defaultManager] modifyReminder:self.reminder withReadState:YES];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReminderDetailAudioCell" owner:self options:nil] ;
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
        _labelDesc.text = self.reminder.desc;
    }
}

@end
