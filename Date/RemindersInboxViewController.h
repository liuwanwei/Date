//
//  RemindersInboxViewController.h
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindersBaseViewController.h"

typedef enum {
    DataTypeCollectingBox = 0,
    DataTypeToday = 1,
    DataTypeRecent = 2,
    DataTypeHistory
}DataType;

@interface RemindersInboxViewController : RemindersBaseViewController

@property (nonatomic) DataType dataType;

- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;

- (void)initData;
- (void)showLoginViewController;

@end
