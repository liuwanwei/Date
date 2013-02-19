//
//  FutureReminderCell.m
//  date
//
//  Created by lixiaoyu on 13-2-19.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "FutureReminderCell.h"

@implementation FutureReminderCell

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
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"FutureReminderCell" owner:self options:nil] ;
        self = [nib objectAtIndex:0];
        self.contentView.backgroundColor  = [UIColor whiteColor];
        self.backgroundView = [[[NSBundle mainBundle] loadNibNamed:@"TodayReminderCellBackgroundView" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

- (void)setReminder:(Reminder *)reminder {
    self.imageViewContactOriX = 120.0;
    [super setReminder:reminder];
    self.oneDay = [self custumDayString:self.reminder.triggerTime];

    NSString * dateTime;
    if (ReminderTypeReceiveAndNoAlarm == [reminder.type integerValue]) {
        dateTime = self.oneDay;
        self.imageViewVoice.frame = CGRectMake(60, self.imageViewVoice.frame.origin.y, self.imageViewVoice.frame.size.width, self.imageViewVoice.frame.size.height);
        self.imageViewContact.frame = CGRectMake(self.imageViewContact.frame.origin.x - 40, self.imageViewContact.frame.origin.y, self.imageViewContact.frame.size.width, self.imageViewContact.frame.size.height);
    }else{
        dateTime = self.oneDay;
        self.imageViewVoice.frame = CGRectMake(100, self.imageViewVoice.frame.origin.y, self.imageViewVoice.frame.size.width, self.imageViewVoice.frame.size.height);
        
        dateTime = [dateTime stringByAppendingString:@" "];
        dateTime = [dateTime stringByAppendingString:self.triggerTime];
    }
    
    self.labelTriggerDate.text = dateTime;
}
@end
