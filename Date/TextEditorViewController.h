//
//  TextEditorViewController.h
//  Date
//
//  Created by Liu Wanwei on 12-12-31.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderSettingViewController.h"

@interface TextEditorViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView * textView;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, weak) ReminderSettingViewController * parentController;

@end
