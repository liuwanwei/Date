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
        [_networkQueue setQueueDidFinishSelector:@selector(queueComplete:)];
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

#pragma 静态函数
+ (HttpRequestManager *)defaultManager {
    if (nil == sHttpRequestManager) {
        sHttpRequestManager = [[HttpRequestManager alloc] init];
    }
    
    return sHttpRequestManager;
}

#pragma 类成员函数
- (void)registerUserRequest:(NSString *)userID withBilateralFriends:(NSArray *)friends {
    if (nil != userID && nil != friends) {
        NSString * url = [kServerUrl stringByAppendingString:kRegisterUserParams];
        NSString  * param;
        NSArray * array = [[BilateralFriendManager defaultManager] allFriendsID];
        if (nil != array) {
            NSInteger size = array.count;
            for (NSInteger index = 0;index < size;index++) {
                if (index == 0) {
                    param = [array objectAtIndex:index];
                }else {
                    param = [param stringByAppendingString:@","];
                    param = [param stringByAppendingString:[array objectAtIndex:index]];
                }
            }
            
            ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
            [request setPostValue:param forKey:@"bidirectional_follower"];
            [request setTimeOutSeconds:30];
            [request setUserInfo:[NSDictionary dictionaryWithObject:@"register" forKey:@"request"]];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
            [request setShouldContinueWhenAppEntersBackground:YES];
#endif
            [_networkQueue addOperation:request];
            [_networkQueue go];
        }
    }
}

#pragma AsiNetWorkQueue delegate
- (void)requestComplete:(ASIHTTPRequest *)request {
    NSString * requestType = [request.userInfo objectForKey:@"request"];
    if ([requestType isEqualToString:@"register"]) {
        NSLog(@"recive register response");
        [self handleRegisterResponse:[request responseData]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"ASIHTTPRequest error:%@",request.error);
}

@end
