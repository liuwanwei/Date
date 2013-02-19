//
//  Reminder.h
//  date
//
//  Created by lixiaoyu on 13-2-6.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSNumber * audioLength;
@property (nonatomic, retain) NSString * audioUrl;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * isAlarm;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSDate * triggerTime;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSDate * finishedTime;

@end
