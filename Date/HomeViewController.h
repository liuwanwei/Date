//
//  HomeViewController.h
//  yueding
//
//  Created by maoyu on 12-11-8.
//  Copyright (c) 2012年 maoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

typedef enum {
    TagsHomeCellImage = 1,
    TagsHomeCellBadge = 2,
    TagsHomeCellNickname = 3
}TagsHomeCell;

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UITableViewCell * homeCell;

@end
