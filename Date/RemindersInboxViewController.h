//
//  RemindersInboxViewController.h
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindersBaseViewController.h"

typedef enum {
    DataTypeCollectingBox = 0,
    DataTypeToday = 1,
    DataTypeRecent = 2,
    DataTypeHistory
}DataType;

typedef enum {
    InfoModeAudio = 0,
    InfoModeText
}InfoMode;

@interface RemindersInboxViewController : RemindersBaseViewController<UITextFieldDelegate>

@property (nonatomic) DataType dataType;
@property (weak, nonatomic) IBOutlet UIButton * btnMode;
@property (weak, nonatomic) IBOutlet UIButton * btnAudio;
@property (weak, nonatomic) IBOutlet UITextField  * txtDesc;
@property (weak, nonatomic) IBOutlet UIToolbar * toolbar;
@property (weak, nonatomic) IBOutlet UIView * toolbarView;

- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;

- (IBAction)changeInfoMode:(UIButton *)sender;

- (void)initData;
- (void)showLoginViewController;

@end
