//
//  ReminderInboxCell.h
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderBaseCell.h"

@interface ReminderInboxCell : ReminderBaseCell

@property (weak, nonatomic) IBOutlet UIButton * btnMark;
@property (weak, nonatomic) IBOutlet UILabel * labelBellSign;

@end
