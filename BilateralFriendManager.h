//
//  BilateralFriendManager.h
//  Date
//
//  Created by maoyu on 12-11-12.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseManager.h"
#import "BilateralFriend.h"

typedef enum {
    OperateTypeAdd = 0,
    OperateTypeSub
}OperateType;

@interface BilateralFriendManager : BaseManager

+ (BilateralFriendManager *)defaultManager;

- (BOOL)analyzeData:(NSArray *)data;
- (BilateralFriend *)newFriend:(NSNumber *)userID withName:(NSString *)name withImageUrl:(NSString *)imageUrl withState:(BOOL)state;

- (NSArray *)allFriendsID;
- (NSArray *)newOnlineFriends;
- (NSArray *)haveReminderFriends;
- (NSArray *)allOnlineFriends;
- (NSMutableDictionary *)friendsWithId:(NSArray *) usersId;
- (BilateralFriend *)bilateralFriendWithUserID:(NSNumber *)userID;

- (void)modifyLastReminder:(NSString *)reminderId withUserId:(NSNumber *)userId;
- (void)modifyUnReadRemindersSizeWithUserId:(NSNumber *)userId withOperateType:(OperateType) operateType;

- (void)modifyReadState:(BilateralFriend *)friend withState:(BOOL)state;

- (void)checkRegisteredFriendsRequest;
- (void)handleCheckRegisteredFriendsResponse:(id)json;
@end
