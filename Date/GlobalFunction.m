//
//  GlobalFunction.m
//  date
//
//  Created by maoyu on 13-1-7.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "GlobalFunction.h"
#import "LMLibrary.h"
static GlobalFunction * sGlobalFunction;

@implementation GlobalFunction

+ (GlobalFunction *)defaultGlobalFunction{
    if (nil == sGlobalFunction) {
        sGlobalFunction = [[GlobalFunction alloc] init];
    }
    
    return sGlobalFunction;
}

- (void)setNavigationBarBackgroundImage:(UINavigationBar *)navigationBar{
    UIImage * image = [UIImage imageNamed:@"navigationBarBg"];
    [navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    navigationBar.tintColor = RGBColor(242, 242, 242);
    UIFont * font = [UIFont systemFontOfSize:20.0];
    NSValue * offset = [NSValue valueWithUIOffset:UIOffsetMake(0, 2)];
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:font, UITextAttributeFont,RGBColor(0, 0, 0), UITextAttributeTextColor,[UIColor whiteColor],UITextAttributeTextShadowColor,offset,UITextAttributeTextShadowOffset,nil];
    [navigationBar setTitleTextAttributes:attr];
   
}

- (void)initNavleftBarItemWithController:(UIViewController *)controller withAction:(SEL)action{
    if (action != nil) {
        controller.navigationItem.hidesBackButton = YES;
        UIButton *leftButton;
        UIBarButtonItem * item;
        
        leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [leftButton setImage:[UIImage imageNamed:@"backNavigationBar"] forState:UIControlStateNormal];
        [leftButton addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
        item = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        controller.navigationItem.leftBarButtonItem = item;
    }else {
        controller.navigationItem.leftBarButtonItem = nil;
    }
}

- (UIColor *)viewBackground {
    return RGBColor(255,255,255);
}

- (NSString *)custumDateString:(NSString *)date withShowDate:(BOOL)show{
    NSString * dateString;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    
    NSDate * nowDate = [NSDate date];
    nowDate = [formatter dateFromString:[formatter stringFromDate:nowDate]];
    NSDate * startDate = [formatter dateFromString:date];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSDayCalendarUnit;
    
    //取相距时间额
    NSDateComponents * cps = [calendar components:unitFlags fromDate:nowDate  toDate:startDate  options:0];
    NSInteger diffDay  = [cps day];
    if (diffDay == 0) {
        dateString = @"今天";
    }else if (diffDay == 1) {
        dateString = @"明天";
    }else if (diffDay == -1) {
        dateString = @"昨天";
    }else {
        if (YES == show) {
            [formatter setDateFormat:@"MM-dd"];
            date = [formatter stringFromDate:startDate];
            dateString = date;
        }else {
            dateString = @"日期";
        }
    }
    return dateString;
}

- (NSString *)custumDayString:(NSDate *)date {
    NSString * dateString;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    
    NSDate * nowDate = [NSDate date];
    nowDate = [formatter dateFromString:[formatter stringFromDate:nowDate]];
    date = [formatter dateFromString:[formatter stringFromDate:date]];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSDayCalendarUnit;
    
    //取相距时间额
    NSDateComponents * cps = [calendar components:unitFlags fromDate:nowDate  toDate:date  options:0];
    NSInteger diffDay  = [cps day];
    if (diffDay == 0) {
        dateString = @"今天";
    }else if (diffDay == 1) {
        dateString = @"明天";
    }else if (diffDay == 2) {
        dateString = @"后天";
    }else if (diffDay == -1) {
        dateString = @"昨天";
    }else {
        [formatter setDateFormat:@"MM-dd"];
        dateString = [formatter stringFromDate:date];
    }
    return dateString;
}

- (NSString *)custumDateTimeString:(NSDate *)date {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * datetimeString = [self custumDayString:date];
    [formatter setDateFormat:@"HH:mm"];
    datetimeString = [datetimeString stringByAppendingString:@" "];
    datetimeString = [datetimeString stringByAppendingString:[formatter stringFromDate:date]];
    
    return datetimeString;
}

@end
