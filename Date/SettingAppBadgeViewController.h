//
//  SettingAppBadgeViewController.h
//  date
//
//  Created by maoyu on 13-1-10.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"

@interface SettingAppBadgeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@property (weak, nonatomic) SettingViewController * parentController;
@end
