//
//  HttpRequestManager.h
//  Date
//
//  Created by maoyu on 12-11-13.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequestManager : NSObject

+ (HttpRequestManager *)defaultManager;

- (void)registerUserRequest:(NSString *)userID withBilateralFriends:(NSArray *)friends;

@end
