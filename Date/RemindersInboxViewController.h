//
//  RemindersInboxViewController.h
//  date
//
//  Created by maoyu on 12-12-5.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindersBaseViewController.h"
#import "EGORefreshTableHeaderView.h"

typedef enum {
    InfoModeAudio = 0,
    InfoModeText
}InfoMode;

@interface RemindersInboxViewController : RemindersBaseViewController<UITextFieldDelegate,EGORefreshTableHeaderDelegate>

@property (nonatomic) DataType dataType;
@property (weak, nonatomic) IBOutlet UIButton * btnMode;
@property (weak, nonatomic) IBOutlet UIButton * btnAudio;
@property (weak, nonatomic) IBOutlet UITextField  * txtDesc;
@property (weak, nonatomic) IBOutlet UIToolbar * toolbar;
@property (weak, nonatomic) IBOutlet UIView * toolbarView;
@property (weak, nonatomic) IBOutlet UILabel * labelPrompt;

- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;

- (IBAction)changeInfoMode:(UIButton *)sender;

- (void)initDataWithAnimation:(BOOL)animation;

@end
