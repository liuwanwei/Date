//
//  UserManager.h
//  Date
//
//  Created by maoyu on 12-11-12.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

@property (weak, nonatomic) NSString *userID;
@property (weak, nonatomic) NSString *screenName;
@property (weak, nonatomic) NSString *imageUrl;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSDate *expirationDate;
@property (nonatomic, copy) NSString *refreshToken;
@property (weak, nonatomic) NSString *oneselfId;

+ (UserManager *)defaultManager;

- (void)storeUserAuthData:(NSString *)userID withAccessToken:(NSString *)accessToken withExpirationDate:(NSDate *)expirationDate;
- (void)removeUserAuthData;

- (void)storeUserData:(NSString *)screenName withImageUrl:(NSString *)imageUrl;
- (void)removeUserData;

- (void)registerUserRequest;
- (BOOL)analyzeData:(NSDictionary *)data;

- (void)updateDeviceTokenRequest:(NSString *)deviceToken;
- (void)handleUpdateDeviceTokenResponse:(id)json;
@end
