//
//  UserManager.m
//  Date
//
//  Created by maoyu on 12-11-12.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "UserManager.h"
#import "BilateralFriendManager.h"
#import "HttpRequestManager.h"

static UserManager * sUserManager;

@implementation UserManager {

}

@synthesize userID = _userID;
@synthesize screenName = _screenName;
@synthesize imageUrl = _imageUrl;
@synthesize accessToken = _accessToken;
@synthesize expirationDate = _expirationDate;
@synthesize refreshToken = _refreshToken;

#pragma 私有函数
- (BOOL)checkJsonValue:(id)value{
    return [value isKindOfClass:[NSString class]];
}

- (void)registerForRemoteNotification {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
}

#pragma 类成员函数
+ (UserManager *)defaultManager {
    if (nil == sUserManager) {
        sUserManager = [[UserManager alloc] init];
    }
    
    return sUserManager;
}

- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}


- (void)storeUserAuthData:(NSString *)userID withAccessToken:(NSString *)accessToken withExpirationDate:(NSDate *)expirationDate {
    
    if (userID == nil ||
   accessToken == nil ||
expirationDate == nil) {
        return;
    }
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              accessToken, @"AccessTokenKey",
                              expirationDate, @"ExpirationDateKey",
                              userID, @"UserIDKey",
                              nil, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void)removeUserAuthData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (NSString *)userID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * userAuthData = [defaults objectForKey:@"SinaWeiboAuthData"];

    return [userAuthData objectForKey:@"UserIDKey"];
}

- (NSString *)accessToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * userAuthData = [defaults objectForKey:@"SinaWeiboAuthData"];

    return [userAuthData objectForKey:@"AccessTokenKey"];
}

- (NSDate *)expirationDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * userAuthData = [defaults objectForKey:@"SinaWeiboAuthData"];

    return [userAuthData objectForKey:@"ExpirationDateKey"];
}

- (void)storeUserData:(NSString *)screenName withImageUrl:(NSString *)imageUrl {
    if (nil == screenName ||
        nil == imageUrl) {
        return;
    }
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              screenName, @"ScreenNameKey",
                              imageUrl, @"ImageUrlKey", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"UserData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeUserData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserData"];
}

- (NSString *)screenName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * userData = [defaults objectForKey:@"UserData"];

    return [userData objectForKey:@"ScreenNameKey"];
}

- (NSString *)imageUrl {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * userData = [defaults objectForKey:@"UserData"];

    return [userData objectForKey:@"ImageUrlKey"];
}

- (void)registerUserRequest {
    [[HttpRequestManager defaultManager] registerUserRequest];
}

- (BOOL)analyzeData:(NSDictionary *)wrapped {
    id screenName = [wrapped objectForKey:kSinaWeiboScreenNameKey];
    if (! [self checkJsonValue:screenName]) {
        return NO;
    }
    
    id imageUrl = [wrapped objectForKey:kSinaWeiboProfileImageUrlKey];
    if (![self checkJsonValue:imageUrl]) {
        return NO;
    }
    
    [self storeUserData:screenName withImageUrl:imageUrl];
    long long userId = [[self userID] longLongValue];

    [[BilateralFriendManager defaultManager] newFriend:[NSNumber numberWithLongLong:userId] withName:screenName withImageUrl:imageUrl withState:YES];
    [self registerForRemoteNotification];
    return YES;
}

- (void)updateDeviceTokenRequest:(NSString *)deviceToken {
    [[HttpRequestManager defaultManager] updateDeviceTokenRequest:deviceToken];
}

- (void)handleUpdateDeviceTokenResponse:(id)json {
    if (nil != json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSString * status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"success"]) {
            
            }
        }
    }

}

@end
