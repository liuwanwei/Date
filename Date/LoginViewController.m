//
//  LoginViewController.m
//  yueding
//
//  Created by maoyu on 12-11-8.
//  Copyright (c) 2012年 maoyu. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "UserManager.h"
#import "SinaWeiboManager.h"

@interface LoginViewController () {
    UserManager * _userManager;
    SinaWeiboManager * _sinaWeiboManager;
}

@end

@implementation LoginViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _sinaWeiboManager = [SinaWeiboManager defaultManager];
        _userManager = [UserManager defaultManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Login:(UIButton *)sender {
    [_sinaWeiboManager.sinaWeibo logIn];
}

@end
