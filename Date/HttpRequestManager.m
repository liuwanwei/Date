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
#import "ReminderManager.h"
#import "DocumentManager.h"

static HttpRequestManager * sHttpRequestManager;

@interface HttpRequestManager () {
    ASINetworkQueue * _networkQueue;
    NSString * _serverUrl;
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
    if (nil != data) {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (nil == error) {
            return json;
        }
    }
   
    NSLog(@"serializationJson error = %@",error.description);
    return nil;
}

- (void)handleRegisterResponse:(NSData *)responseData {
    id json = [self serializationJson:responseData];
    [[BilateralFriendManager defaultManager] handleCheckRegisteredFriendsResponse:json];
    [[ReminderManager defaultManager] getRemoteRemindersRequest];
}

- (void)handleNewReminderReponse:(NSData *)responseData {
    id json = [self serializationJson:responseData];
    [[ReminderManager defaultManager] handleNewReminderResponse:json];
}

- (void)handleRemoteRemindersReponse:(NSData *)responseData {
    id json = [self serializationJson:responseData];
    [[ReminderManager defaultManager] handleRemoteRemindersResponse:json];
}

- (void)handleDownAudioFileReponse:(NSDictionary *)userInfo withErrorCode:(NSInteger)code {
    [[ReminderManager defaultManager] handleDowanloadAuioFileResponse:userInfo withErrorCode:code];
}

- (void)handleCheckRegisteredFriendsReponse:(NSData *)responseData {
    id json = [self serializationJson:responseData];
    [[BilateralFriendManager defaultManager] handleCheckRegisteredFriendsResponse:json];
}

- (void)handleUpdateReminderReadStateResponse:(NSData *)responseData withUserInfo:(NSDictionary *)userInfo{
    id json = [self serializationJson:responseData];
    Reminder * reminder = [userInfo objectForKey:@"reminder"];
    [[ReminderManager defaultManager] handleUpdateReminderReadStateResponse:json withReminder:reminder];
}

- (void)updateDeviceTokenResponse:(NSData *)responseData {
    id json = [self serializationJson:responseData];
    [[UserManager defaultManager] handleUpdateDeviceTokenResponse:json];
}

- (void)handleDeleteReminderResponse:(NSData *)responseData withUserInfo:(NSDictionary *)userInfo {
    id json = [self serializationJson:responseData];
    Reminder * reminder = [userInfo objectForKey:@"reminder"];
    [[ReminderManager defaultManager] handleDeleteReminderResponse:json withReminder:reminder];
}

/*
 按标准对好友数据进行格式化
 */
- (NSString *)formatFollower{
    NSString * param = nil;
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
    }
    
    return param;
}

/*
 保存服务器模式，用于测试方便使用
 */
- (void)storeServerMode:(NSInteger)mode {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:mode] forKey:@"ServerMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _serverUrl = nil;
}

- (ServerMode)serverMode {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * mode = [defaults objectForKey:@"ServerMode"];
    if (nil == mode) {
        mode = [NSNumber numberWithInteger:ServerModeRemote];
    }
    
    return [mode integerValue];
}

- (NSString *)serverUrl {
    NSString * url = nil;
    if (nil == _serverUrl) {
        if (ServerModeLocal == [self serverMode]) {
            url = kLocalServerUrl;
        }else {
            url = kRemoteServerUrl;
        }
    }
    
    return url;
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
    NSString * url = [[self serverUrl] stringByAppendingString:kRegisterUserParams];
    NSString  * param = [self formatFollower];
    if (nil != param) {
        ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        [request setPostValue:[UserManager defaultManager].userID forKey:@"userId"];
        [request setPostValue:[UserManager defaultManager].screenName forKey:@"nickname"];
        [request setPostValue:param forKey:@"biFollower"];
        [request setTimeOutSeconds:20];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"register" forKey:@"request"]];
        [request setShouldContinueWhenAppEntersBackground:YES];
        [_networkQueue addOperation:request];
        [_networkQueue go];
    }
}

- (void)sendReminderRequest:(Reminder *)reminder {
    NSString * url = [[self serverUrl] stringByAppendingString:kSendReminderParams];
           
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setPostValue:[UserManager defaultManager].userID forKey:@"senderId"];
    [request setPostValue:[reminder.userID stringValue] forKey:@"targetId"];
    if (nil != reminder.audioUrl && ![reminder.audioUrl isEqualToString:@""]) {
        [request setFile:reminder.audioUrl forKey:@"audio"];
    }
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * triggerTime;
    if (nil != reminder.triggerTime) {
        triggerTime = [formatter stringFromDate:reminder.triggerTime];
        [request setPostValue:@"0" forKey:@"state"];
    }else {
        triggerTime = [formatter stringFromDate:[NSDate date]];
        [request setPostValue:@"1" forKey:@"state"];
    }
    [request setPostValue:triggerTime forKey:@"triggerTime"];
    [request setPostValue:reminder.longitude forKey:@"longitude"];
    [request setPostValue:reminder.latitude forKey:@"latitude"];
    [request setPostValue:reminder.desc forKey:@"description"];
    [request setPostValue:reminder.audioLength forKey:@"audioLength"];
    [request setTimeOutSeconds:10];
    [request setUserInfo:[NSDictionary dictionaryWithObject:@"newReminder" forKey:@"request"]];
    [_networkQueue addOperation:request];
    [_networkQueue go];
}

- (void)getRemoteRemindersRequest:(NSString *)timeline {
    NSString * url = [[self serverUrl] stringByAppendingString:kGetRemindersParams];
    
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setPostValue:[UserManager defaultManager].userID forKey:@"userId"];
    [request setPostValue:timeline forKey:@"timeline"];
    
    [request setTimeOutSeconds:10];
    [request setUserInfo:[NSDictionary dictionaryWithObject:@"remoteReminders" forKey:@"request"]];
    [_networkQueue addOperation:request];
    [_networkQueue go];
}

- (void)downloadAudioFileRequest:(Reminder *)reminder {
    NSString * path;
    if ([[self serverUrl] isEqualToString:kLocalServerUrl]) {
        path = [[self serverUrl] stringByAppendingString:reminder.audioUrl];
    }else  {
        path = reminder.audioUrl;
    }
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

- (void)checkRegisteredFriendsRequest {
    NSString * url = [[self serverUrl] stringByAppendingString:kCheckRegisteredFriendsParams];
    NSString  * param = [self formatFollower];
    if (nil != param) {
        ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        [request setPostValue:[UserManager defaultManager].userID forKey:@"userId"];
        [request setPostValue:param forKey:@"biFollower"];
        [request setTimeOutSeconds:10];
        [request setUserInfo:[NSDictionary dictionaryWithObject:@"checkRegisteredFriends" forKey:@"request"]];
        [request setShouldContinueWhenAppEntersBackground:YES];
        [_networkQueue addOperation:request];
        [_networkQueue go];
    }
}

- (void)updateReminderReadStateRequest:(Reminder *)reminder withReadState:(BOOL)state {
    NSString * url = [[self serverUrl] stringByAppendingString:kUpdateReminderReadStateParams];
    url = [NSString stringWithFormat:url,reminder.id,[UserManager defaultManager].userID,state];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeOutSeconds:10];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"updateReminderReadState",@"request",reminder,@"reminder",nil]];
    [_networkQueue addOperation:request];
    [_networkQueue go];
}

- (void)updateDeviceTokenRequest:(NSString *)deviceToken {
    NSString * url = [[self serverUrl] stringByAppendingString:kUpdateDeviceTokenParams];
    url = [NSString stringWithFormat:url,[UserManager defaultManager].userID,deviceToken];
    
    NSURL * URL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:URL];
    [request setTimeOutSeconds:10];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"updateDeviceToken",@"request",nil]];
    [_networkQueue addOperation:request];
    [_networkQueue go];
}

- (void)deleteReminderRequest:(Reminder *)reminder {
    NSString * url = [[self serverUrl] stringByAppendingString:kDeleteReminderParams];
    url = [NSString stringWithFormat:url,reminder.id];
    
    ASIHTTPRequest *request;
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeOutSeconds:20];
    [request setUserInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"deleteReminder",@"request",reminder,@"reminder",nil]];
    [_networkQueue addOperation:request];
    [_networkQueue go];

}

#pragma AsiNetWorkQueue delegate
- (void)requestComplete:(ASIHTTPRequest *)request {
    NSString * requestType = [request.userInfo objectForKey:@"request"];
    if ([requestType isEqualToString:@"register"]) {
        [self handleRegisterResponse:[request responseData]];
    }else if ([requestType isEqualToString:@"newReminder"]) {
        [self handleNewReminderReponse:[request responseData]];
    }else if ([requestType isEqualToString:@"remoteReminders"]){
        [self handleRemoteRemindersReponse:[request responseData]];
    }else if ([requestType isEqualToString:@"downAudioFile"]) {
        [self handleDownAudioFileReponse:request.userInfo withErrorCode:[request responseStatusCode]];
    }else if ([requestType isEqualToString:@"checkRegisteredFriends"]) {
        [self handleCheckRegisteredFriendsReponse:[request responseData]];
    }else if ([requestType isEqualToString:@"updateReminderReadState"]) {
        [self handleUpdateReminderReadStateResponse:[request responseData] withUserInfo:request.userInfo];
    }else if ([requestType isEqualToString:@"updateDeviceToken"]) {
        [self updateDeviceTokenResponse:[request responseData]];
    }else if ([requestType isEqualToString:@"deleteReminder"]) {
        [self handleDeleteReminderResponse:[request responseData] withUserInfo:request.userInfo];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSString * requestType = [request.userInfo objectForKey:@"request"];
    if ([requestType isEqualToString:@"newReminder"]) {
        [self handleNewReminderReponse:nil];
    }else if ([requestType isEqualToString:@"updateDeviceToken"]) {
        //NSString * error = request.error.description;
    }else if ([requestType isEqualToString:@"deleteReminder"]) {
        [self handleDeleteReminderResponse:nil withUserInfo:request.userInfo];
    }
}

@end
