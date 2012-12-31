//
//  CustomChoiceViewController.m
//  Date
//
//  Created by Liu Wanwei on 12-12-31.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "CustomChoiceViewController.h"
#import "AppDelegate.h"

@interface CustomChoiceViewController ()

@end

@implementation CustomChoiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
