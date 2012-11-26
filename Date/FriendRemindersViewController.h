//
//  FriendRemindersViewController.h
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendRemindersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) NSNumber * userId;

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end
