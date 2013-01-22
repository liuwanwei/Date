//
//  ReminderManager.m
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//
#import "ReminderManager.h"
#import "HttpRequestManager.h"
#import "LMLibrary.h"
#import "UserManager.h"
#import "SoundManager.h"
#import "AppDelegate.h"

static ReminderManager * sReminderManager;

typedef enum {
    BadgeOperateAdd = 0,
    BadgeOperateSub
}BadgeOperate;

@interface ReminderManager () {
  
}

@end

@implementation ReminderManager
@synthesize delegate = _delegate;

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
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:remindersId];
    request.predicate = predicate;
    results = [self executeFetchRequest:request];

    if (nil == results || results.count == 0) {
        return nil;
    }
    return results;
}


- (NSString *)timeline {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    formatter.timeZone = timeZone;
    NSString * timeline =  [formatter stringFromDate:[NSDate date]];
    return timeline;
}

/*
 获取上次更新提醒的时间
 */
- (NSString *)getTimeline {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * timeline = [defaults objectForKey:kRemoteRemindersUpdateTimeline];
    if (nil == timeline) {
        timeline = [self timeline];
    }
    return timeline;
}

/*
 保存上次更新提醒的时间
 */
- (void)saveTimeline {
    [[NSUserDefaults standardUserDefaults] setObject:[self timeline] forKey:kRemoteRemindersUpdateTimeline];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 保存从服务器获取到的数据。
 新加reminder表数据的同时，修改BilateralFriend表
 */
- (void)saveRemotesReminders:(NSArray *)data {
    BOOL isBell;
    Reminder * reminder;
    BilateralFriend * friend;

    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * triggerTime;
    NSString * reminderId;
    for (id object in data) {
        isBell = NO;
        if ([object isKindOfClass:[NSDictionary class]]) {
            reminderId = [object objectForKey:@"id"];
            if (nil == [self reminderWithId:reminderId]) {
                reminder = (Reminder *)[NSEntityDescription insertNewObjectForEntityForName:kReminderEntity inManagedObjectContext:self.managedObjectContext];
                reminder.id = [object objectForKey:@"id"];
                reminder.audioUrl = [object objectForKey:@"audio"];
                reminder.desc = [object objectForKey:@"description"];
                reminder.userID = [numberFormatter numberFromString:[object objectForKey:@"senderId"]];
                reminder.createTime = [dateFormatter dateFromString:[object objectForKey:@"createTime"]];
                reminder.latitude = [object objectForKey:@"latitude"];
                reminder.longitude = [object objectForKey:@"longitude"];
                reminder.type = [NSNumber numberWithInteger:ReminderTypeReceive];
                reminder.isRead = [NSNumber numberWithBool:YES];
                reminder.audioLength = [numberFormatter numberFromString:[object objectForKey:@"audioLength"]];
                        
                triggerTime = [object objectForKey:@"triggerTime"];
                if ([triggerTime isEqualToString:@"0"]) {
                    reminder.triggerTime = nil;
                }else {
                    reminder.triggerTime = [dateFormatter dateFromString:triggerTime];
                                            isBell = YES;
                    reminder.isAlarm = [NSNumber numberWithBool:NO];
                    [self updateRemindersSizeWith:reminder.triggerTime withOperate:BadgeOperateAdd];
                }
                        
                [self synchroniseToStore];
                       
                if (YES == isBell) {
                    friend = [[BilateralFriendManager defaultManager]bilateralFriendWithUserID:reminder.userID];
                    [self addLocalNotificationWithReminder:reminder withBilateralFriend:friend];
                }
            }
        }
        
        if ([data count] > 0) {
            [self saveTimeline];
        }
        NSNotification * notification = nil;
        notification = [NSNotification notificationWithName:kRemindesUpdateMessage object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

/*
 下载完音频数据后，修改数据库音频相关字段
 */
- (void)modifyReminderAudioUrl:(NSString *)path withAudioTime:(NSInteger)time withReminder:(Reminder *)reminder{
    reminder.audioUrl = path;
    //reminder.audioLength = [NSNumber numberWithInteger:time];
    [self synchroniseToStore];
}

/*
 通过关键值获取已经添加的本地通知对象
 */
- (UILocalNotification *)localNotification:(NSString *)reminderId {
    UILocalNotification * localNotification = nil;
    UIApplication * app = [UIApplication sharedApplication];
    NSArray * localArray = [app scheduledLocalNotifications];
    if (nil != localArray) {
        NSDictionary * dict;
        NSString * value;
        for (localNotification in localArray) {
            dict = localNotification.userInfo;
            value = [dict objectForKey:@"key"];
            if ([value isEqualToString:reminderId]) {
                break;
            }
            localNotification = nil;
        }
    }
    
    return localNotification;
}

- (void)remindersSize {
    [self collectingBoxReminders];
    [self recentUnFinishedReminders];
}

- (void)updateRemindersSizeWith:(NSDate *)triggerTime withOperate:(BadgeOperate)operate {
    NSDate * today = [NSDate date];
    NSDate * tomorrow;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    today = [formatter dateFromString:[formatter stringFromDate:today]];
    tomorrow = [today dateByAddingTimeInterval:24*60*60];

    if (nil == triggerTime) {
        if (BadgeOperateAdd == operate) {
            _draftRemindersSize++;
        }else if (BadgeOperateSub == operate && 0 != _draftRemindersSize) {
            _draftRemindersSize--;
        }
    }else {
        BOOL sign = NO;
        if ([triggerTime compare:tomorrow] == NSOrderedAscending) {
            sign = YES;
        }
        
        if (BadgeOperateAdd == operate) {
            if (YES == sign) {
                _todayRemindersSize ++;
            }
            _allRemindersSize++;
        }else if (BadgeOperateSub == operate) {
            if (YES == sign && 0 != _todayRemindersSize) {
                _todayRemindersSize --;
            }
            if (0 != _allRemindersSize) {
                _allRemindersSize --;
            }
        }
    }
    
    [self updateAppBadge];
}

#pragma 静态函数
+ (ReminderManager *)defaultManager {
    if (nil == sReminderManager) {
        sReminderManager = [[ReminderManager alloc] init];
    }
    
    return sReminderManager;
}

#pragma 类成员函数
- (void)saveSentReminder:(Reminder *)reminder {
    if (YES == [[UserManager defaultManager] isOneself:[reminder.userID stringValue]] 
        || nil == reminder.triggerTime) {
        reminder.isAlarm = [NSNumber numberWithBool:NO];
        reminder.type = [NSNumber numberWithInteger:ReminderTypeReceive];
        if (nil != reminder.triggerTime) {
             [self addLocalNotificationWithReminder:reminder withBilateralFriend:nil];
        }
    }else {
        reminder.isAlarm = [NSNumber numberWithBool:YES];
        reminder.type = [NSNumber numberWithInteger:ReminderTypeSend];
    }
    reminder.isRead = [NSNumber numberWithBool:YES];
    
    Reminder * newReminder = [[Reminder alloc] initWithEntity:[NSEntityDescription entityForName: kReminderEntity inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
    newReminder.audioUrl = reminder.audioUrl;
    newReminder.desc = reminder.desc;
    newReminder.id = reminder.id;
    newReminder.isAlarm = reminder.isAlarm;
    newReminder.isRead = reminder.isRead;
    newReminder.latitude = reminder.latitude;
    newReminder.longitude = reminder.longitude;
    newReminder.createTime = reminder.createTime;
    newReminder.triggerTime = reminder.triggerTime;
    newReminder.type = reminder.type;
    newReminder.userID = reminder.userID;
    newReminder.audioLength = reminder.audioLength;
    
    if (! [self synchroniseToStore]) {
        return;
    }
    NSNotification * notification = nil;
    notification = [NSNotification notificationWithName:kRemindesUpdateMessage object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)deleteReminder:(Reminder *)reminder {
    [self cancelLocalNotificationWithReminder:reminder];
    if (ReminderStateUnFinish == [reminder.state integerValue]) {
         [self updateRemindersSizeWith:reminder.triggerTime withOperate:BadgeOperateSub];
    }
    [[SoundManager defaultSoundManager] deleteAudioFile:reminder.audioUrl];
    [self deleteFromStore:reminder synchronized:YES];
}

- (void)modifyReminder:(Reminder *)reminder withTriggerTime:(NSDate *)triggerTime withDesc:(NSString *)desc {
    if (nil != reminder) {
        reminder.desc = desc;
        BOOL sign = NO;
        if ((nil == reminder.triggerTime && nil != triggerTime) ||
            (nil != reminder.triggerTime && nil == triggerTime) ||
            ([reminder.triggerTime compare:triggerTime] != NSOrderedSame)) {
            sign = YES;
            reminder.isAlarm = [NSNumber numberWithBool:NO];
            reminder.triggerTime = triggerTime;
        }
        
        if (! [self synchroniseToStore]) {
            return;
        }

        if (YES == sign) {
            [self cancelLocalNotificationWithReminder:reminder];
            if ([[reminder.userID stringValue] isEqualToString:[UserManager defaultManager].oneselfId] ) {
                [[ReminderManager defaultManager] addLocalNotificationWithReminder:reminder withBilateralFriend:nil];
            }else {
                BilateralFriend * friend = [[BilateralFriendManager defaultManager]bilateralFriendWithUserID:reminder.userID];
                [[ReminderManager defaultManager] addLocalNotificationWithReminder:reminder withBilateralFriend:friend];
            }
            
            //[self updateAppBadge];
        }

        NSNotification * notification = nil;
        notification = [NSNotification notificationWithName:kRemindesUpdateMessage object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];

    }
}

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

- (NSArray *)remindersWithUserId:(NSNumber *)userId {
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID = %@",userId];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sendTime" ascending:NO];

    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    
    if (nil == results || results.count == 0) {
        return nil;
    }
    return results;
    
}

- (NSArray *)remindersExpired {
    NSDate * date = [NSDate date];
    //NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy-MM-dd"];
    //NSDate * startDate = [formatter dateFromString:[formatter stringFromDate:date]];
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"type = %d AND isAlarm = NO AND triggerTime < %@",ReminderTypeReceive,date];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"triggerTime" ascending:NO];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    
    if (nil == results || results.count == 0) {
        return nil;
    }
    return results;
}

- (Reminder *)reminder {
    Reminder * reminder = [[Reminder alloc] initWithEntity:[NSEntityDescription entityForName: kReminderEntity inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil] ;
    return reminder;
}

- (void)sendReminder:(Reminder *)reminder {
    if (YES == [[UserManager defaultManager] isOneself:[reminder.userID stringValue]] || nil == reminder.triggerTime) {
        NSString * reminderId = [[NSDate date] description];
        [self updateRemindersSizeWith:reminder.triggerTime withOperate:BadgeOperateAdd];
        
        reminder.id = reminderId;
        reminder.createTime = [NSDate date];
        [self saveSentReminder:reminder];
        
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(newReminderSuccess:)]) {
                [self.delegate performSelector:@selector(newReminderSuccess:) withObject:reminderId];
            }
        }
    }else {
        [[HttpRequestManager defaultManager] sendReminderRequest:reminder];
    }
    
}

- (void)handleNewReminderResponse:(id)json {
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
                NSString * reminderId = [json objectForKey:@"data"];
                if (self.delegate != nil) {
                    if ([self.delegate respondsToSelector:@selector(newReminderSuccess:)]) {
                        [self.delegate performSelector:@selector(newReminderSuccess:) withObject:reminderId];
                    }
                }
            }else {
                if (self.delegate != nil) {
                    if ([self.delegate respondsToSelector:@selector(newReminderFailed)]) {
                        [self.delegate performSelector:@selector(newReminderFailed) withObject:nil];
                    }
                }
            }
        }
    }else {
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(newReminderFailed)]) {
                [self.delegate performSelector:@selector(newReminderFailed) withObject:nil];
            }
        }
    }
}

/*
 请求新的约定信息
 */
- (void)getRemoteRemindersRequest {
    [[HttpRequestManager defaultManager] getRemoteRemindersRequest:[self getTimeline]];
}

- (void)handleRemoteRemindersResponse:(id)json {
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
                id data = [json objectForKey:@"data"];
                if ([data isKindOfClass:[NSArray class]]) {
                    [self saveRemotesReminders:data];
                }
            }
        }
    }
}

- (void)downloadAudioFileWithReminder:(Reminder *)reminder {
    [[HttpRequestManager defaultManager] downloadAudioFileRequest:reminder];
}

- (void)handleDowanloadAuioFileResponse:(NSDictionary *)userInfo withErrorCode:(NSInteger)code {
    Reminder * reminder = [userInfo objectForKey:@"reminder"];
    if (200 == code) {
        NSString * audioPath = [userInfo objectForKey:@"destinationPath"];
        //NSInteger audioTime = [[SoundManager defaultSoundManager] audioTime:audioPath];
        [self modifyReminderAudioUrl:audioPath withAudioTime:0 withReminder:reminder];
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(downloadAudioFileSuccess:)]) {
                [self.delegate performSelector:@selector(downloadAudioFileSuccess:) withObject:reminder];
            }
        }
    }else {
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(downloadAudioFileFailed:)]) {
                [self.delegate performSelector:@selector(downloadAudioFileFailed:) withObject:reminder];
            }
        }
    }
}

- (void)updateReminderReadStateRequest:(Reminder *)reminder withReadState:(BOOL)state {
    [[HttpRequestManager defaultManager] updateReminderReadStateRequest:reminder withReadState:state];
}

- (void)handleUpdateReminderReadStateResponse:(id)json withReminder:(Reminder *)reminder {
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
                if (nil != reminder) {
                    if (self.delegate != nil) {
                        if ([self.delegate respondsToSelector:@selector(updateReminderReadStateSuccess:)]) {
                            [self.delegate performSelector:@selector(updateReminderReadStateSuccess:) withObject:reminder];
                        }
                    }
                }
            }
        }
    }
}

- (void)deleteReminderRequest:(Reminder *)reminder {
    [[HttpRequestManager defaultManager] deleteReminderRequest:reminder];
}

- (void)handleDeleteReminderResponse:(id)json withReminder:(Reminder *)reminder {
    BOOL success = NO;
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
                if (nil != reminder) {
                    success = YES;
                    if (self.delegate != nil) {
                        if ([self.delegate respondsToSelector:@selector(deleteReminderSuccess:)]) {
                            [self.delegate performSelector:@selector(deleteReminderSuccess:) withObject:reminder];
                        }
                    }
                }
            }
        }
    }
    
    if (NO == success) {
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(deleteReminderFailed)]) {
                [self.delegate performSelector:@selector(deleteReminderFailed) withObject:nil];
            }
        }
    }
}

- (void)addLocalNotificationWithReminder:(Reminder *)reminder withBilateralFriend:(BilateralFriend *)friend{
    if (nil == [self localNotification:reminder.id] && nil != reminder.triggerTime) {
        NSString * body = @"提醒:";
//        if (nil == friend) {
//            body = @"您自己的提醒:";
//        }else if ([[friend.userID stringValue] isEqualToString:[UserManager defaultManager].oneselfId]) {
//             body = @"您自己的提醒:";
//        }else {
//            body = [friend.nickname stringByAppendingString:@" 提醒你:"];
//        }
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        body = [body stringByAppendingString:[formatter stringFromDate:reminder.triggerTime]];
        body = [body stringByAppendingString:@" "];
        body = [body stringByAppendingString:reminder.desc];
        
        UILocalNotification * newNotification = [[UILocalNotification alloc] init];
        newNotification.fireDate = reminder.triggerTime;
        newNotification.alertBody = body;
        newNotification.repeatInterval = 0;
        newNotification.soundName = [[SoundManager defaultSoundManager] alertSound];
        newNotification.alertAction = @"查看应用";
        newNotification.timeZone=[NSTimeZone defaultTimeZone];
        newNotification.userInfo = [NSDictionary dictionaryWithObject:reminder.id forKey:@"key"];
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
    }
}

- (void)cancelLocalNotificationWithReminder:(Reminder *)reminder {
    UILocalNotification * localNotification = [self localNotification:reminder.id];
    if (nil != localNotification) {
        NSLog(@"cancelLocalNotificationWithReminder");
        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
    }
}

- (void)modifyReminder:(Reminder *)reminder withReadState:(BOOL)isRead {
    reminder.isRead = [NSNumber numberWithBool:isRead];
    [self synchroniseToStore];
    if (YES == isRead) {
        //[[BilateralFriendManager defaultManager] modifyUnReadRemindersSizeWithUserId:reminder.userID withOperateType:OperateTypeSub];
    }
    NSNotification * notification = nil;
    notification = [NSNotification notificationWithName:kRemindesUpdateMessage object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)modifyReminder:(Reminder *)reminder withBellState:(BOOL)isBell {
    reminder.isAlarm = [NSNumber numberWithBool:isBell];
     NSLog(@"withBellState");
    if (YES == isBell) {
        NSLog(@"isBell == YES");
        [self cancelLocalNotificationWithReminder:reminder];
    }
    [self synchroniseToStore];
}

- (void)modifyReminder:(Reminder *)reminder withState:(ReminderState)state {
    reminder.state = [NSNumber numberWithInteger:state];
    if (ReminderStateFinish == state) {
        reminder.isAlarm = [NSNumber numberWithBool:YES];
        [self cancelLocalNotificationWithReminder:reminder];
        [self updateRemindersSizeWith:reminder.triggerTime withOperate:BadgeOperateSub];
    }else {
        if (nil != reminder.triggerTime) {
            NSDate * nowDate = [NSDate date];
            if ([nowDate compare:reminder.triggerTime] == NSOrderedAscending) {
                //未过期) {
                reminder.isAlarm = [NSNumber numberWithBool:NO];
                BilateralFriend * friend = [[BilateralFriendManager defaultManager]bilateralFriendWithUserID:reminder.userID];
                [self addLocalNotificationWithReminder:reminder withBilateralFriend:friend];
                [self updateRemindersSizeWith:reminder.triggerTime withOperate:BadgeOperateAdd];
            }
        }
    }
    
    [self synchroniseToStore];
    
}

- (void)modifyReminder:(Reminder *)reminder withType:(ReminderType)type {
    reminder.type = [NSNumber numberWithInteger:type];
    [self synchroniseToStore];
}

- (NSArray *)allRemindersWithReimnderType:(ReminderType)type {
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sendTime" ascending:NO];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"type = %d",type];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    
    if (nil == results || results.count == 0) {
        return nil;
    }
    return results;
}

- (NSArray *)recentUnFinishedReminders {
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"triggerTime" ascending:YES];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(state = 0 AND type = %d AND triggerTime >= %@) OR (state = 0 AND type = %d AND triggerTime < %@)",ReminderTypeReceive,[formatter dateFromString:[formatter stringFromDate:date]],ReminderTypeReceive,[formatter dateFromString:[formatter stringFromDate:date]]];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    
    if (nil == results || results.count == 0) {
        _allRemindersSize = 0;
        [self updateAppBadge];
        return nil;
    }else {
        _allRemindersSize = [results count];
    }
    [self updateAppBadge];
    return results;
}

- (NSArray *)todayUnFinishedReminders {
    NSDate * today = [NSDate date];
    NSDate * tomorrow;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    today = [formatter dateFromString:[formatter stringFromDate:today]];
    tomorrow = [today dateByAddingTimeInterval:24*60*60];
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"triggerTime" ascending:YES];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(state = 0 AND type = %d AND triggerTime >= %@ AND triggerTime < %@) OR (state = 0 AND type = %d AND triggerTime < %@)",ReminderTypeReceive,today,tomorrow,ReminderTypeReceive,today];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    
    if (nil == results || results.count == 0) {
        _todayRemindersSize = 0;
        [self updateAppBadge];
        return nil;
    }else {
        _todayRemindersSize = [results count];
    }
    [self updateAppBadge];
    return results;
}

- (NSArray *)historyReminders {
    NSDate * today = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    today = [formatter dateFromString:[formatter stringFromDate:today]];
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"triggerTime" ascending:NO];
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(type = %d AND triggerTime < %@) OR (type = %d AND triggerTime >= %@ AND state = 1) OR (type = %d AND triggerTime = null AND state = 1)",ReminderTypeReceive,today,ReminderTypeReceive,today,ReminderTypeReceive];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"type = %d AND state = 1",ReminderTypeReceive];

    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    
    if (nil == results || results.count == 0) {
        return nil;
    }
    
    return results;
}

- (NSArray *)collectingBoxReminders {
    NSDate * today = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    today = [formatter dateFromString:[formatter stringFromDate:today]];
    NSArray * results = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createTime" ascending:NO];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"type = %d AND triggerTime = null AND state = 0",ReminderTypeReceive];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    results = [self executeFetchRequest:request];
    
    if (nil == results || results.count == 0) {
        _draftRemindersSize = 0;
        [self updateAppBadge];
        return nil;
    }else {
        _draftRemindersSize = [results count];
    }
    [self updateAppBadge];
    return results;
}

- (Reminder *)reminderWithId:(NSString *) reminderId {
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kReminderEntity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id = %@", reminderId];
    request.predicate = predicate;
    
    NSArray * results = [self executeFetchRequest:request];
    if (nil == results || 1 != results.count) {
        return nil;
    }else {
        return [results objectAtIndex:0];
    }
}

- (void)storeAppBadgeMode:(AppBadgeMode)mode {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:mode] forKey:@"AppBadgeMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateAppBadge];
}

- (AppBadgeMode)appBadgeMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * mode = [defaults objectForKey:@"AppBadgeMode"];
    if (mode == nil) {
        [self storeAppBadgeMode:AppBadgeModeToady];
        return AppBadgeModeToady;
    }
    return [mode integerValue];
}

- (void)updateAppBadge {
    AppBadgeMode mode = [self appBadgeMode];
    NSInteger badgeSize = 0;
    //NSArray * reminders;
    if (AppBadgeModeToady == mode) {
        badgeSize = _todayRemindersSize;
        //reminders = [self todayUnFinishedReminders];
    }else if (AppBadgeModeRecent == mode){
        badgeSize = _allRemindersSize;
        //reminders = [self recentUnFinishedReminders];
    }
//    if (nil != reminders) {
//        badgeSize = [reminders count];
//    }else {
//        badgeSize = 0;
//    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeSize];
}

- (void)computeRemindersSize {
     NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(remindersSize) object:nil];
    [thread start];
}

@end
