//
//  ReminderSettingDescCell.m
//  date
//
//  Created by lixiaoyu on 12-12-24.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderSettingDescCell.h"

@implementation ReminderSettingDescCell
@synthesize labelTitle = _labelTitle;
@synthesize labelDesc = _labelDesc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReminderSettingDescCell" owner:self options:nil] ;
        self = [nib objectAtIndex:0];
        _labelDesc.numberOfLines = 0;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
