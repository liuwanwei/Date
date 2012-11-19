//
//  ReminderManager.m
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//
#import "ReminderManager.h"
#import "Reminder.h"

static ReminderManager * sReminderManager;

@implementation ReminderManager

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

- (NSArray *)remindersWithIdPredicate:(NSString *) remindersId {
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kBilateralFriendEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:remindersId];
    request.predicate = predicate;
    results = [self executeFetchRequest:request];

    if (nil == results || results.count == 0) {
        return nil;
    }
    return results;
}

#pragma 静态函数
+ (ReminderManager *)defaultManager {
    if (nil == sReminderManager) {
        sReminderManager = [[ReminderManager alloc] init];
    }
    
    return sReminderManager;
}

#pragma 类成员函数
- (NSMutableDictionary *)remindersWithId:(NSArray *) remindersId {
    NSMutableDictionary * results = nil;
    if (nil == remindersId) {
        return nil;
    }else {
        NSInteger size = remindersId.count;
        NSString * predicate = nil;
        for (NSInteger index = 0; index < size; index++) {
            if (index == 0) {
                predicate = [NSString stringWithFormat:@"id = %@", [remindersId objectAtIndex:index]] ;
            }else {
                predicate = [predicate stringByAppendingString:@" OR "];
                predicate = [predicate stringByAppendingString: predicate = [NSString stringWithFormat:@"id = %@", [remindersId objectAtIndex:index]]] ;
            }
        }
    
        NSArray * reminders = [self remindersWithIdPredicate:predicate];
        if (nil != reminders && reminders.count != 0) {
            results = [NSMutableDictionary dictionaryWithCapacity:0];
            for (Reminder * reminder in reminders) {
                [results setObject:reminder forKey:reminder.id];
            }
        }
    }

    return results;
}

@end
