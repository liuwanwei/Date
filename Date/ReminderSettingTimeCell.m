//
//  ReminderSettingTimeCell.m
//  date
//
//  Created by maoyu on 12-12-14.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderSettingTimeCell.h"

@implementation ReminderSettingTimeCell
@synthesize labelTitle = _labelTitle;
@synthesize switchTime = _switchTime;
@synthesize delegate = _delegate;
@synthesize triggerTime = _triggerTime;
@synthesize labelTriggerTime = _labelTriggerTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReminderSettingTimeCell" owner:self options:nil] ;
        self = [nib objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)valueChanged:(UISwitch *)sender {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(valueChangedWithSwitch:)]) {
            [self.delegate performSelector:@selector(valueChangedWithSwitch:) withObject:sender];
        }
    }
}

- (void)setTriggerTime:(NSDate *)triggerTime {
    if (nil == triggerTime) {
        [_switchTime setOn:NO];
        _labelTriggerTime.text = @"";
    }else {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        _labelTriggerTime.text = [dateFormatter stringFromDate:triggerTime];
        [_switchTime setOn:NO];
    }
}

@end
