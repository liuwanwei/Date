//
//  MBProgressManager.h
//  Date
//
//  Created by maoyu on 12-11-21.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBProgressManager : NSObject

+ (MBProgressManager *)defaultManager;

- (void)showHUD:(NSString *)msg;
- (void)removeHUD;

- (void)showIndicator;
- (void)hideIndicator;
@end
