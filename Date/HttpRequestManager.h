//
//  HttpRequestManager.h
//  Date
//
//  Created by maoyu on 12-11-13.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reminder.h"

typedef enum {
    ServerModeLocal = 0,
    ServerModeRemote
}ServerMode;

@interface HttpRequestManager : NSObject

+ (HttpRequestManager *)defaultManager;

- (void)registerUserRequest;
- (void)sendReminderRequest:(Reminder *)reminder;
- (void)getRemoteRemindersRequest:(NSString *)timeline;
- (void)downloadAudioFileRequest:(Reminder *)reminder;
- (void)checkRegisteredFriendsRequest;
- (void)updateReminderReadStateRequest:(Reminder *)reminder withReadState:(BOOL)state;

- (void)storeServerMode:(NSInteger)mode;
- (ServerMode)serverMode;
@end
