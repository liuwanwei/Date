//
//  MenuViewController.h
//  Date
//
//  Created by maoyu on 12-11-30.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton * btnServerMode;
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell * menuCell;
@property (strong, nonatomic) NSIndexPath * lastIndexPath;

- (IBAction)modifyServerMode:(id)sender;
- (IBAction)settingButtonClicked:(id)sender;

@end
