//
//  FriendRemindersViewController.h
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderManager.h"
#import "FriendReminderCell.h"
#import "BilateralFriend.h"
#import "SoundManager.h"

@interface FriendRemindersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,ReminderManagerDelegate,FriendReminderCellDelegate,SoundManagerDelegate>

@property (weak, nonatomic) NSNumber * userId;
@property (weak, nonatomic) BilateralFriend * bilateralFriend;

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end
