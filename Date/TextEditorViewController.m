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

@interface TextEditorViewController () {
}

@end

@implementation TextEditorViewController

@synthesize text = _text;
@synthesize parentController = _parentController;
@synthesize textView = _textView;
@synthesize toolBackgroundView = _toolBackgroundView;

#pragma 私有函数
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = _toolBackgroundView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    
    // set views with new info
    _toolBackgroundView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
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
    
    self.title = @"内容";
    _textView.text = _text;
    _textView.delegate  = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    if (![_parentController.desc isEqualToString:_textView.text]) {
        _parentController.desc = _textView.text;
        [_parentController updateDescCell];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clearText:(id)sender {
    _textView.text = @"";
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self back];
        return NO;
    }
    return YES;
}

@end
