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

@property (strong, nonatomic) NSNumber * userId;
@property (strong, nonatomic) BilateralFriend * bilateralFriend;

@end
