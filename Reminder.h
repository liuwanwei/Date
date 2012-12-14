//
//  Reminder.h
//  date
//
//  Created by maoyu on 12-12-13.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSNumber * audioLength;
@property (nonatomic, retain) NSString * audioUrl;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * isAlarm;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSDate * triggerTime;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSNumber * state;

@end
