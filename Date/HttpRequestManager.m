//
//  HttpRequestManager.m
//  Date
//
//  Created by maoyu on 12-11-13.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "HttpRequestManager.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "BilateralFriendManager.h"
#import "UserManager.h"
#import "BilateralFriend.h"
#import "JSONKit.h"
#import "ReminderManager.h"
#import "DocumentManager.h"

static HttpRequestManager * sHttpRequestManager;

@interface HttpRequestManager () {
    ASINetworkQueue * _networkQueue;
}
@end

@implementation HttpRequestManager

#pragma 私有函数
- (id)init {
    if (self = [super init]) {
        _networkQueue = [[ASINetworkQueue alloc] init];
        _networkQueue.shouldCancelAllRequestsOnFailure = NO;
        _networkQueue.maxConcurrentOperationCount = 10;
        [_networkQueue setRequestDidFinishSelector:@selector(requestComplete:)];
        [_networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [_networkQueue setDelegate:self];
    }
    
    return self;
}

- (id)serializationJson:(NSData *)data {
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (nil == error) {
        return json;
    }
    
    NSLog(@"serializationJson error = %@",error.description);
    return nil;
}

- (void)handleRegisterResponse:(NSData *)responseData {
    id json = [self serializationJson:responseData];
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
                id data = [json objectForKey:@"data"];
                if ([data isKindOfClass:[NSArray class]]) {
                    [[BilateralFriendManager defaultManager] checkRegisteredFriends:data];
                }
            }
        }
    }
}

- (void)handleNewReminderReponse:(NSData *)responseData {
    id json = [self serializationJson:responseData];
    [[ReminderManager defaultManager] handleNewReminderResponse:json];
}

- (void)handleRemoteRemindersReponse:(NSData *)responseData {
    id json = [self serializationJson:responseData];
    [[ReminderManager defaultManager] handleRemoteRemindersResponse:json];
}

- (void)handleDownAudioFileReponse:(NSDictionary *)userInfo {
    [[ReminderManager defaultManager] handleDowanloadAuioFileResponse:userInfo];
}

#pragma 静态函数
+ (HttpRequestManager *)defaultManager {
    if (nil == sHttpRequestManager) {
        sHttpRequestManager = [[HttpRequestManager alloc] init];
    }
    
    return sHttpRequestManager;
}

#pragma 类成员函数
- (void)registerUserRequest {
        NSString * url = [kServerUrl stringByAppendingString:kRegisterUserParams];
        NSString  * param;
        NSArray * array = [[BilateralFriendManager defaultManager] allFriendsID];
        if (nil != array) {
            BilateralFriend * friend;
            NSInteger size = array.count;
            for (NSInteger index = 0;index < size;index++) {
                if (index == 0) {
                    friend = [array objectAtIndex:index];
                    param = [friend.userID stringValue];
                }else {
                    param = [param stringByAppendingString:@","];
                    friend = [array objectAtIndex:index];
                    param = [param stringByAppendingString:[friend.userID stringValue]];
                }
            }
            
            ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
            [request setPostValue:[UserManager defaultManager].userID forKey:@"userId"];
            [request setPostValue:[UserManager defaultManager].screenName forKey:@"nickname"];
            [request setPostValue:param forKey:@"biFollower"];
            [request setTimeOutSeconds:30];
            [request setUserInfo:[NSDictionary dictionaryWithObject:@"register" forKey:@"request"]];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
            [request setShouldContinueWhenAppEntersBackground:YES];
#endif
            [_networkQueue addOperation:request];
            [_networkQueue go];
        }
}

- (void)sendReminderRequest:(Reminder *)reminder {
    NSString * url = [kServerUrl stringByAppendingString:kSendReminderParams];
           
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setPostValue:[UserManager defaultManager].userID forKey:@"senderId"];
    [request setPostValue:[reminder.userID stringValue] forKey:@"targetId"];
    [request setFile:reminder.audioUrl forKey:@"audio"];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * triggerTime = [formatter stringFromDate:reminder.triggerTime];
    [request setPostValue:triggerTime forKey:@"triggerTime"];
    [request setPostValue:reminder.longitude forKey:@"longitude"];
    [request setPostValue:reminder.latitude forKey:@"latitude"];
    [request setPostValue:reminder.adress forKey:@"description"];
    [request setTimeOutSeconds:20];
    [request setUserInfo:[NSDictionary dictionaryWithObject:@"newReminder" forKey:@"request"]];
    [_networkQueue addOperation:request];
    [_networkQueue go];
}

- (void)getRemoteRemindersRequest:(NSString *)timeline {
    NSString * url = [kServerUrl stringByAppendingString:kGetRemindersParams];
    
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setPostValue:[UserManager defaultManager].userID forKey:@"userId"];
    [request setPostValue:timeline forKey:@"timeline"];
    
    [request setTimeOutSeconds:20];
    [request setUserInfo:[NSDictionary dictionaryWithObject:@"remoteReminders" forKey:@"request"]];
    [_networkQueue addOperation:request];
    [_networkQueue go];
}

- (void)downloadAudioFileRequest:(Reminder *)reminder {
    NSString * path = [kServerUrl stringByAppendingString:reminder.audioUrl];
    DocumentManager * manager = [DocumentManager defaultManager];
    
    NSString * destinationPath =  [manager pathForRandomSoundWithSuffix:@"m4a"].relativePath;
    ASIHTTPRequest *request;
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:path]];
    [request setDownloadDestinationPath:destinationPath];
    [request setTimeOutSeconds:20];
    [request setUserInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"downAudioFile",@"request",reminder,@"reminder",destinationPath,@"destinationPath",nil]];
    [_networkQueue addOperation:request];
    [_networkQueue go];
}

#pragma AsiNetWorkQueue delegate
- (void)requestComplete:(ASIHTTPRequest *)request {
    NSString * requestType = [request.userInfo objectForKey:@"request"];
    if ([requestType isEqualToString:@"register"]) {
        NSLog(@"recive register response");
        [self handleRegisterResponse:[request responseData]];
    }else if ([requestType isEqualToString:@"newReminder"]) {
        NSLog(@"recive newReminder response");
        [self handleNewReminderReponse:[request responseData]];
    }else if ([requestType isEqualToString:@"remoteReminders"]){
        NSLog(@"recive remoteReminders response");
        [self handleRemoteRemindersReponse:[request responseData]];
    }else if ([requestType isEqualToString:@"downAudioFile"]) {
        // FIXME 需要根据状态进行判断是否成功,后果是音频不能播放
        NSInteger statue = [request responseStatusCode];
        [self handleDownAudioFileReponse:request.userInfo];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"ASIHTTPRequest error:%@",request.error);
}

@end
