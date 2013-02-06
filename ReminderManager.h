//
//  ReminderManager.h
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseManager.h"
#import "Reminder.h"
#import "BilateralFriendManager.h"

typedef enum {
    ReminderTypeReceive = 0,
    ReminderTypeSend = 1,
    ReminderTypeReceiveAndNoAlarm = 2,
    ReminderTypeSendAndNoAlarm
}ReminderType;

typedef enum {
    ReminderStateUnFinish = 0,
    ReminderStateFinish = 1
}ReminderState;

typedef enum {
    AppBadgeModeBlank = 0,
    AppBadgeModeToady = 1,
    AppBadgeModeRecent
}AppBadgeMode;

@protocol ReminderManagerDelegate <NSObject>

@optional
- (void)newReminderSuccess:(NSString *)reminderId;
- (void)newReminderFailed;
- (void)downloadAudioFileSuccess:(Reminder *)reminder;
- (void)downloadAudioFileFailed:(Reminder *)reminder;
- (void)updateReminderReadStateSuccess:(Reminder *)reminder;
- (void)deleteReminderSuccess:(Reminder *)reminder;
- (void)deleteReminderFailed;
@end

@interface ReminderManager : BaseManager

@property (weak, nonatomic) id<ReminderManagerDelegate> delegate;
@property (nonatomic) NSInteger draftRemindersSize;
@property (nonatomic) NSInteger todayRemindersSize;
@property (nonatomic) NSInteger allRemindersSize;

+ (ReminderManager *)defaultManager;

- (Reminder *)reminder;
- (Reminder *)reminderWithId:(NSString *) reminderId;

- (void)saveSentReminder:(Reminder *)reminder;
- (void)deleteReminder:(Reminder *)reminder;
- (void)modifyReminder:(Reminder *)reminder withTriggerTime:(NSDate *)triggerTime withDesc:(NSString *)desc withType:(ReminderType)type;

- (NSMutableDictionary *)remindersWithId:(NSArray *) remindersId;
- (NSArray *)remindersWithUserId:(NSNumber *)userId;
- (NSArray *)remindersExpired;
- (NSArray *)allRemindersWithReimnderType:(ReminderType) type;
- (NSArray *)recentUnFinishedReminders;
- (NSArray *)todayUnFinishedReminders;
- (NSArray *)historyReminders;
- (NSArray *)collectingBoxReminders;
- (NSArray *)futureReminders;

- (void)createDefaultReminders;

- (void)computeRemindersSize;

- (void)sendReminder:(Reminder *)reminder;
- (void)handleNewReminderResponse:(id)json;

- (void)getRemoteRemindersRequest;
- (void)handleRemoteRemindersResponse:(id)json;

- (void)downloadAudioFileWithReminder:(Reminder *)reminder;
- (void)handleDowanloadAuioFileResponse:(NSDictionary *)userInfo withErrorCode:(NSInteger)code;

- (void)updateReminderReadStateRequest:(Reminder *)reminder withReadState:(BOOL)state;
- (void)handleUpdateReminderReadStateResponse:(id)json withReminder:(Reminder *)reminder;

- (void)deleteReminderRequest:(Reminder *)reminder;
- (void)handleDeleteReminderResponse:(id)json withReminder:(Reminder *)reminder;

- (void)addLocalNotificationWithReminder:(Reminder *)reminder;
- (void)cancelLocalNotificationWithReminder:(Reminder *)reminder;

- (void)modifyReminder:(Reminder *)reminder withReadState:(BOOL)isRead;
- (void)modifyReminder:(Reminder *)reminder withBellState:(BOOL)isBell;
- (void)modifyReminder:(Reminder *)reminder withState:(ReminderState)state;
- (void)modifyReminder:(Reminder *)reminder withType:(ReminderType)type;

- (void)storeAppBadgeMode:(AppBadgeMode)mode;
- (AppBadgeMode)appBadgeMode;
- (void)updateAppBadge;
@end
