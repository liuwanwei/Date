//
//  BaseViewController.m
//  date
//
//  Created by maoyu on 12-12-19.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "PPRevealSideViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma 私有函数
// move view to right side
- (void)moveToRightSide {
    [self animateHomeViewToSide:CGRectMake(220.0f,
                                           self.navigationController.view.frame.origin.y,
                                           self.navigationController.view.frame.size.width,
                                           self.navigationController.view.frame.size.height)];
}

// animate home view to side rect
- (void)animateHomeViewToSide:(CGRect)newViewRect {
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.navigationController.view.frame = newViewRect;
                     }
                     completion:^(BOOL finished){
                         UIControl *overView = [[UIControl alloc] init];
                         overView.tag = 10086;
                         overView.backgroundColor = [UIColor clearColor];
                         overView.frame = self.navigationController.view.frame;
                         [overView addTarget:self action:@selector(restoreViewLocation) forControlEvents:UIControlEventTouchDown];
                         [[[UIApplication sharedApplication] keyWindow] addSubview:overView];
                     }];
}

#pragma 类成员函数
// restore view location
- (void)restoreViewLocation {
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.navigationController.view.frame = CGRectMake(0,
                                                                           self.navigationController.view.frame.origin.y,
                                                                           self.navigationController.view.frame.size.width,
                                                                           self.navigationController.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         UIControl *overView = (UIControl *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:10086];
                         [overView removeFromSuperview];
                         [AppDelegate delegate].menuViewController.view.hidden = YES;
                     }];
}

- (void)initMenuButton {
    //UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftMenuUp"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBtnTapped:)];

    UIButton * leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];

    UIBarButtonItem * leftItem;
    UIImage *bgUpImg = [[UIImage imageNamed:@"leftMenuUp"]
                      resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    UIImage *bgDownImg = [[UIImage imageNamed:@"leftMenuDown"]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [leftButton setBackgroundImage:bgUpImg forState:UIControlStateNormal];
    [leftButton setBackgroundImage:bgDownImg forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(leftBarBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.contentMode = UIViewContentModeCenter;
    leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}
#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftBarBtnTapped:(id)sender {
    MenuViewController * menuVC = [AppDelegate delegate].menuViewController;
    PPRevealSideViewController * revealVC = [[AppDelegate delegate] revealSideViewController];
    [revealVC pushViewController:menuVC onDirection:PPRevealSideDirectionLeft animated:YES];
    
    
    return;
   
    if (menuVC.view.hidden) {
        menuVC.view.hidden = NO;
    }
    
    [menuVC.tableView reloadData];
    
    [self moveToRightSide];
}

@end
