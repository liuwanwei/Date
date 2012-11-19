//
//  BilateralFriendManager.h
//  Date
//
//  Created by maoyu on 12-11-12.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseManager.h"

@interface BilateralFriendManager : BaseManager

+ (BilateralFriendManager *)defaultManager;

- (BOOL)analyzeData:(NSArray *)data;

- (NSArray *)allFriendsID;
- (NSArray *)newOnlineFriends;
- (NSArray *)haveReminderFriends;
- (void)checkRegisteredFriends:(NSArray *)data;
@end
