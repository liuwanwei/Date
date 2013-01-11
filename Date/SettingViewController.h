//
//  SettingViewController.h
//  date
//
//  Created by maoyu on 12-12-13.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindersBaseViewController.h"

@interface SettingViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@property (strong, nonatomic) NSArray * appBadgeSignRows;
@property (strong ,nonatomic) NSArray * appSnsInfo;
@property (nonatomic) AppBadgeMode appBadgeMode;

- (void)updateAppBadgeCell;
- (void)updateSNSCell;
- (BOOL)isLogin;
- (BOOL)isAuthValid;
- (NSString *)sinaNickname;

@end
