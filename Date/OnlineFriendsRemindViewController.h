//
//  OnlineFriendsRemindViewController.h
//  Date
//
//  Created by maoyu on 12-11-15.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIFriendImageTag    = 1,
    UIFriendNameTag     = 2,
    
} TagsOnlineFriendRemindCell;

@interface OnlineFriendsRemindViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UITableViewCell * friendCell;

@end
