//
//  FriendRemindersViewController.h
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendReminderCell.h"
#import "BilateralFriend.h"
#import "RemindersBaseViewController.h"

@interface FriendRemindersViewController : RemindersBaseViewController

@property (weak, nonatomic) NSNumber * userId;
@property (weak, nonatomic) BilateralFriend * bilateralFriend;

@end
