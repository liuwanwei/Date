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

- (UIColor *)navigationItemTintColor{
    return [UIColor colorWithRed:0.137 green:0.557 blue:0.867 alpha:0.5];
}

+ (GlobalFunction *)defaultGlobalFunction{
    if (nil == sGlobalFunction) {
        sGlobalFunction = [[GlobalFunction alloc] init];
    }
    
    return sGlobalFunction;
}

- (void)setNavigationBarBackgroundImage:(UINavigationBar *)navigationBar{
    UIImage * image = [UIImage imageNamed:@"navigationBarBg"];
    [navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    navigationBar.tintColor = self.navigationItemTintColor;
    [navigationBar.titleTextAttributes setValue:RGBColor(232, 224, 213) forKey:UITextAttributeTextColor];
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

@end
