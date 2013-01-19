//
//  TextEditorViewController.m
//  Date
//
//  Created by Liu Wanwei on 12-12-31.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "TextEditorViewController.h"
#import "AppDelegate.h"

#define LeftMarge 5

@interface TextEditorViewController ()

@end

@implementation TextEditorViewController

@synthesize text = _text;
@synthesize parentController = _parentController;
@synthesize textView = _textView;

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
    
    self.title = @"内容";
    _textView.text = _text;
    _textView.delegate  = self;
    [_textView becomeFirstResponder];
    [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_textView resignFirstResponder];
}

- (void)back{
    [_textView resignFirstResponder];
    _parentController.desc = _textView.text;
    [_parentController updateDescCell];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self back];
        return NO;
    }
    return YES;
}

@end
