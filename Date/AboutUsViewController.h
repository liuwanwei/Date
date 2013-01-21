//
//  AboutUsViewController.h
//  date
//
//  Created by maoyu on 13-1-19.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "BaseViewController.h"

@interface AboutUsViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end
