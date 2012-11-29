//
//  SinaWeiboManager.m
//  Date
//
//  Created by maoyu on 12-11-12.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "SinaWeiboManager.h"
#import "UserManager.h"
#import "BilateralFriendManager.h"
#import "LMLibrary.h"

#define bilateralFriendsUpdateDate 24*60*60
static SinaWeiboManager * sWeiboManager;

@interface SinaWeiboManager () {
    UserManager * _userManager;
    BOOL _finishUserInfo;
    BOOL _finishFriendsInfo;
}
@end

@implementation SinaWeiboManager
@synthesize sinaWeibo = _sinaWeibo;

+ (SinaWeiboManager *)defaultManager {
    if (nil == sWeiboManager) {
        sWeiboManager = [[SinaWeiboManager alloc] init];
    }
    
    return sWeiboManager;
}

# pragma 私有函数
- (BOOL)checkUpdateCycle {
    BOOL result = NO;
    NSDate * now = [NSDate date];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSDate * updateDate = [defaults objectForKey:kSinaWeiboBilateralFriendsUpdateDate];
    if (nil == updateDate) {
        updateDate = [now dateByAddingTimeInterval:bilateralFriendsUpdateDate];
        result = YES;
    }else {
        if ([now compare:updateDate] == NSOrderedDescending) {
            updateDate = [now dateByAddingTimeInterval:bilateralFriendsUpdateDate];
            result = YES;
        }
    }
    
    if (YES == result) {
        [[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:kSinaWeiboBilateralFriendsUpdateDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return result;
}

- (void)initSinaWeibo {
    _userManager = [UserManager defaultManager];
    
    _sinaWeibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI ssoCallbackScheme:kAppSsoCallbackScheme andDelegate:nil];
    
    _sinaWeibo.accessToken = _userManager.accessToken;
    _sinaWeibo.expirationDate = _userManager.expirationDate;
    _sinaWeibo.userID = _userManager.userID;
    
    _sinaWeibo.delegate = self;
    
    _finishUserInfo = NO;
    _finishFriendsInfo = NO;
}

- (void)handleGetAddressRequest:(NSDictionary *)result {
    id geos = [result objectForKey:@"geos"];
    if ([geos isKindOfClass:[NSArray class]]) {
        NSArray * array = (NSArray *)geos;
        for (NSInteger index = 0; index < array.count; index++) {
            NSDictionary * dictionary = [array objectAtIndex:index];
            id adress = [dictionary objectForKey:@"address"];
            id name = [dictionary objectForKey:@"name"];
            NSString * value;
            if ([adress isKindOfClass:[NSString class] ]) {
                value = adress;
            }
            if ([name isKindOfClass:[NSString class] ]) {
                value = [value stringByAppendingString:name];
            }
            NSNotification * notification = nil;
            notification = [NSNotification notificationWithName:kGetAddressMessage object:nil userInfo:[NSMutableDictionary dictionaryWithObject:value forKey:@"address"]];
            
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        
    }
}

# pragma 类成员函数
- (void)requestUserInfo {
    [_sinaWeibo requestWithURL:kSinaWiboGetUserInfoUrl
                        params:[NSMutableDictionary dictionaryWithObject:_sinaWeibo.userID forKey:@"uid"]
                    httpMethod:@"GET"
                      delegate:self];
}

- (void)requestBilateralFriends {
    if (YES == [self checkUpdateCycle]) {
        [_sinaWeibo requestWithURL:kSinaWeiboGetBilateralFriendsUrl
                            params:[NSMutableDictionary dictionaryWithObjectsAndKeys:_sinaWeibo.userID,@"uid",@"200",@"count",nil]
                        httpMethod:@"GET"
                          delegate:self];
    }
}

- (void)requestAddressWithCoordinate2D:(CLLocationCoordinate2D)coordinate2D {
    NSString * longitude = [NSString stringWithFormat:@"%f",coordinate2D.longitude];
    NSString * latitude = [NSString stringWithFormat:@"%f",coordinate2D.latitude];
    NSString * param = longitude;
    param = [param stringByAppendingString:@","];
    param = [param stringByAppendingString:latitude];
    
    [_sinaWeibo requestWithURL:kSinaWeiboGetAddress params:[NSMutableDictionary dictionaryWithObject:param forKey:@"coordinate"] httpMethod:@"GET" delegate:self];
}

#pragma mark - SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo {
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    
    [_userManager storeUserAuthData:sinaweibo.userID withAccessToken:sinaweibo.accessToken withExpirationDate:sinaweibo.expirationDate];
    NSNotification * notification = nil;
    notification = [NSNotification notificationWithName:kUserOAuthSuccessMessage object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo {
    NSLog(@"sinaweiboDidLogOut");
    [_userManager removeUserAuthData];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo {
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error {
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error {
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [_userManager removeUserAuthData];
}

#pragma mark - SinaWeiboRequest Delegate
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result {
    if ([request.url hasSuffix:kSinaWiboGetUserInfoUrl]) {
        NSLog(@"GetUser success");
        [_userManager analyzeData:result];
        _finishUserInfo  = YES;
    }else if ([request.url hasSuffix:kSinaWeiboGetBilateralFriendsUrl]) {
        if([result isKindOfClass:[NSDictionary class]]) {
             NSLog(@"BilateralFriends success");
            [[BilateralFriendManager defaultManager] analyzeData:result];
            _finishFriendsInfo = YES;
        }
    }else if ([request.url hasSuffix:kSinaWeiboGetAddress]) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            [self handleGetAddressRequest:result];
        }
    }
    
    if (YES == _finishUserInfo && YES == _finishFriendsInfo) {
        _finishUserInfo = NO;
        _finishFriendsInfo = NO;
        
        [[LMLibrary defaultManager] postNotificationWithName:kGoRegisterUserMessage withObject:nil];
    }
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error {
    if ([request.url hasSuffix:kSinaWiboGetUserInfoUrl]) {
        NSLog(@"Post GetUser failed with error : %@", error);
    }else if ([request.url hasSuffix:kSinaWeiboGetBilateralFriendsUrl]) {
         NSLog(@"Post GetBilateralFriends failed with error : %@", error);
    }
}

@end
