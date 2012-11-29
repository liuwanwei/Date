//
//  BilateralFriend.h
//  Date
//
//  Created by maoyu on 12-11-29.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BilateralFriend : NSManagedObject

@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * isOnline;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * lastReminderID;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSNumber * unReadRemindersSize;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSNumber * type;

@end
