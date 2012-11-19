//
//  ReminderManager.h
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseManager.h"

@interface ReminderManager : BaseManager

+ (ReminderManager *)defaultManager;

- (NSMutableDictionary *)remindersWithId:(NSArray *) remindersId;

@end
