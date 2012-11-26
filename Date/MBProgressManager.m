//
//  MBProgressManager.m
//  Date
//
//  Created by maoyu on 12-11-21.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "MBProgressManager.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

static MBProgressManager *sMBProgressManager;

@implementation MBProgressManager {
    MBProgressHUD *_HUD;
}

+ (MBProgressManager *)defaultManager {
    if (nil == sMBProgressManager) {
        sMBProgressManager = [[MBProgressManager alloc] init];
    }
    
    return sMBProgressManager;
}

#pragma 类成员函数
- (void)showHUD:(NSString *)msg {
    [self showIndicator];
    if (nil == _HUD) {
         _HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:_HUD];
    _HUD.labelText = msg;
    [_HUD show:YES];
}

- (void)removeHUD {
    [self hideIndicator];
    [_HUD hide:YES];
    [_HUD removeFromSuperViewOnHide];
}

- (void)showIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
