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

+ (GlobalFunction *)defaultInstance;

- (void)customizeNavigationBar:(UINavigationBar *)navigationBar;

- (IBAction)sharedBackItemClicked:(id)sender;
- (void)initNavleftBarItemWithController:(UIViewController *)controller withAction:(SEL)action;

//- (void)initNavLeftBarCancelItemWithController:(UIViewController *)controller;
- (NSString *)custumDateString:(NSString *)date withShowDate:(BOOL)show;
- (NSString *)custumDateTimeString:(NSDate *)date;
- (NSString *)custumDayString:(NSDate *)date;
- (NSString *)custumDateString2:(NSDate *)date;
- (void)customNavigationBarItem:(UIBarButtonItem *)item;

- (NSInteger)diffDay:(NSDate *)date;

- (NSDate *)tomorrow;

- (UIColor *)viewBackground;

@end
