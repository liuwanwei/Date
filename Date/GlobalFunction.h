//
//  GlobalFunction.h
//  date
//
//  Created by maoyu on 13-1-7.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LocalString(key)  NSLocalizedString(key, nil)

@interface GlobalFunction : NSObject

+ (GlobalFunction *)defaultGlobalFunction;

- (void)setNavigationBarBackgroundImage:(UINavigationBar *)navigationBar;
- (void)initNavleftBarItemWithController:(UIViewController *)controller withAction:(SEL)action;

- (NSString *)custumDateString:(NSString *)date withShowDate:(BOOL)show;
- (NSString *)custumDateTimeString:(NSDate *)date;
- (NSString *)custumDayString:(NSDate *)date;

- (NSDate *)tomorrow;

- (UIColor *)viewBackground;

@end
