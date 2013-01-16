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

@end
