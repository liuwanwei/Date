//
//  BilateralFriendManager.m
//  Date
//
//  Created by maoyu on 12-11-12.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "BilateralFriendManager.h"
#import "HttpRequestManager.h"

static BilateralFriendManager * sBilateralFriendManager;

@implementation BilateralFriendManager

#pragma 私有函数
- (NSArray *)executeFetchRequest:(NSFetchRequest *)request {
    // query.
    NSError * error = nil;
    NSMutableArray * mutableFetchResult = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == mutableFetchResult) {
        NSLog(@"executeFetchRequest error");
        return nil;
    }
    
    return mutableFetchResult;
}

// 查询不在线的好友
- (NSArray *)notOnlineFriends {
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kBilateralFriendEntity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isOnLine = 0"];
    request.predicate = predicate;
    
    results = [self executeFetchRequest:request];
    
    return results;
}

// 查询指定usersID的不在线好友
- (NSArray *)notOnlineFriendsWithUserID:(NSString *) usersID {
    NSString * param = [NSString stringWithFormat:@"isOnline = 0 AND (%@)", usersID];

    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kBilateralFriendEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:param];
    request.predicate = predicate;
    
    results = [self executeFetchRequest:request];
    
    return results;
}

- (void)modifyOnline:(BOOL)online withBilateralFriend:(BilateralFriend *)friend {
    friend.isOnline = [NSNumber numberWithBool:online];
    
    [self synchroniseToStore];
}

- (BilateralFriend *)bilateralFriendWithUserID:(NSNumber *)userID {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kBilateralFriendEntity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID = %@", userID];
    request.predicate = predicate;
    
    NSArray * results = [self executeFetchRequest:request];
    if (nil == results || 1 != results.count) {
        return nil;
    }else {
        return [results objectAtIndex:0];
    }
}

#pragma 静态函数
+ (BilateralFriendManager *)defaultManager {
    if (nil == sBilateralFriendManager) {
        sBilateralFriendManager = [[BilateralFriendManager alloc] init];
    }
    
    return sBilateralFriendManager;
}

#pragma 类成员函数


- (BilateralFriend *)newFriend:(NSNumber *)userID withName:(NSString *)name withImageUrl:(NSString *)imageUrl {
    // check if this friend already exists.
    BilateralFriend * friend = [self bilateralFriendWithUserID:userID];
    
    if (nil != friend) {
        friend.nickname = name;
        friend.imageUrl = imageUrl;
    }else {
        friend = (BilateralFriend *)[NSEntityDescription insertNewObjectForEntityForName:kBilateralFriendEntity inManagedObjectContext:self.managedObjectContext];
        friend.userID = userID;
        friend.nickname = name;
        friend.imageUrl = imageUrl;
    }
    
    if (! [self synchroniseToStore]) {
        return nil;
    }
    
    return friend;
}

/*
 1 解析来自新浪微博返回的用户信息JSON数据
 2 并存储在数据库中
 */
- (BOOL)analyzeData:(NSDictionary *)data {
    BOOL result = NO;
    if (nil != data) {
        id array = [data objectForKey:@"users"];
        if ([array isKindOfClass:[NSArray class]]) {
            NSArray * friendsArray = (NSArray *)array;
            NSInteger size = friendsArray.count;
            id object;
            NSNumber * friendID;
            NSString * nickname;
            NSString * imageUrl;
            for (NSInteger index = 0; index < size; index++) {
                object = [array objectAtIndex:index];
                if ([object isKindOfClass:[NSDictionary class]]) {
                    friendID = [object objectForKey:kSinaWeiboUserIDKey];
                    nickname = [object objectForKey:kSinaWeiboScreenNameKey];
                    imageUrl = [object objectForKey:kSinaWeiboProfileImageUrlKey];
                    [self newFriend:friendID withName:nickname withImageUrl:imageUrl];
                }
            }
            
            result = YES;
        }
    }
    return result;
}

- (NSArray *)allFriendsID {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kBilateralFriendEntity];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"userID", nil]];  
    NSArray * results = [self executeFetchRequest:request];
    return results;
}

- (NSArray *)newOnlineFriends {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kBilateralFriendEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isOnline != NO AND isRead = NO"];
    request.predicate = predicate;
    NSArray * results = [self executeFetchRequest:request];
    return results;
}

- (NSArray *)allOnlineFriends {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kBilateralFriendEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isOnline != NO"];
    request.predicate = predicate;
    NSArray * results = [self executeFetchRequest:request];
    if (nil == results || 0 == results.count) {
        return nil;
    }
    return results;
}

- (void)checkRegisteredFriendsRequest {
    [[HttpRequestManager defaultManager] checkRegisteredFriendsRequest];
}

/*
  检查是否有新的注册用户，修改数据库isOnline字段为YES，并通知界面层进行提醒
 */
- (void)handleCheckRegisteredFriendsResponse:(id)json {
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
                id object = [json objectForKey:@"data"];
                if ([object isKindOfClass:[NSArray class]]) {
                    NSArray * data = (NSArray *)object;
                    NSString * predicate = nil;
                    NSInteger size = data.count;
                    id object;
                    BOOL sign = NO;
                    
                    for (NSInteger index = 0; index < size; index++) {
                        object = [data objectAtIndex:index];
                        if ([object isKindOfClass:[NSDictionary class]]) {
                            if (0 == index) {
                                predicate = [NSString stringWithFormat:@"userID = %@",[object objectForKey:@"userId"]] ;
                            }else {
                                predicate = [predicate stringByAppendingString:@" OR "];
                                predicate = [predicate stringByAppendingString:[NSString stringWithFormat:@"userID = %@",[object objectForKey:@"userId"]]] ;
                            }
                        }
                    }
                    
                    if (nil != predicate) {
                        NSArray * friendsArray = [self notOnlineFriendsWithUserID:predicate];
                        if (nil != friendsArray) {
                            NSLog(@"new online friends");
                            NSInteger friendsArraySize = friendsArray.count;
                            if (friendsArraySize > 0) {
                                sign = YES;
                            }
                            for (NSInteger index = 0; index < friendsArraySize; index++) {
                                [self modifyOnline:YES withBilateralFriend:[friendsArray objectAtIndex:index]];
                            }
                        }
                    }
                    
                    if (YES == sign) {
                        NSNotification * notification = nil;
                        notification = [NSNotification notificationWithName:kOnlineFriendsMessage object:nil];
                        [[NSNotificationCenter defaultCenter] postNotification:notification];
                    }

                }
            }
        }
    }
}

/*
 查询有消息提醒的朋友
 */
- (NSArray *)haveReminderFriends {
    NSArray * results;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kBilateralFriendEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"lastReminderID != 0"];
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    if (nil == results || results.count == 0) {
        return nil;
    }
    return results;
}

/*
 收到新的约定信息后，进行有关数据的更新
 */
- (void)modifyLastReminder:(NSString *)reminderId withUserId:(NSNumber *)userId {
    BilateralFriend * friend = [self bilateralFriendWithUserID:userId];

    if (nil != friend) {
        friend.lastReminderID = reminderId;
        [self synchroniseToStore];
    }
}

/*
 当提醒信息是否读标示，被置为为YES时，调用此函数
 */
- (void)modifyUnReadRemindersSizeWithUserId:(NSNumber *)userId withOperateType:(OperateType) operateType {
    BilateralFriend * friend = [self bilateralFriendWithUserID:userId];
    if (nil != friend) {
        NSInteger size;
        if (operateType == OperateTypeAdd) {
            size = [friend.unReadRemindersSize integerValue] + 1;
        }else {
            size = [friend.unReadRemindersSize integerValue] - 1;
        }
        friend.unReadRemindersSize = [NSNumber numberWithInteger:size];
        [self synchroniseToStore];
    }
}

/*
 当新好友提醒界面关闭的时候，修改状态为已读
 */
- (void)modifyReadState:(BilateralFriend *)friend withState:(BOOL)state {
    friend.isRead = [NSNumber numberWithBool:state];
    [self synchroniseToStore];
}

@end
