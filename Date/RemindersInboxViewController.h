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
#import "InsetsTextField.h"
#import "JTTableViewGestureRecognizer.h"

typedef enum {
    InfoModeAudio = 0,
    InfoModeText
}InfoMode;

@interface RemindersInboxViewController : RemindersBaseViewController<UITextFieldDelegate,EGORefreshTableHeaderDelegate, UIAlertViewDelegate,JTTableViewGestureEditingRowDelegate>

@property (nonatomic) DataType dataType;
@property (weak, nonatomic) IBOutlet UIButton * btnMode;
@property (weak, nonatomic) IBOutlet UIButton * btnAudio;
@property (weak, nonatomic) IBOutlet InsetsTextField  * txtDesc;
@property (weak, nonatomic) IBOutlet UIToolbar * toolbar;
@property (weak, nonatomic) IBOutlet UIView * toolbarView;
@property (weak, nonatomic) IBOutlet UILabel * labelPrompt;
@property (weak, nonatomic) IBOutlet UIView * viewBottomMenu;

- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;

- (IBAction)showBottomMenuView:(id)sender;

- (void)initDataWithAnimation:(BOOL)animation;

@end
