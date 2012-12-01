//
//  MenuViewController.h
//  Date
//
//  Created by maoyu on 12-11-30.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton * btnServerMode;

- (IBAction)modifyServerMode:(id)sender;

- (void)setVisible:(BOOL)visible;

@end
