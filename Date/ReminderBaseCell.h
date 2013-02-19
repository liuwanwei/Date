//
//  ReminderBaseCell.h
//  date
//
//  Created by lixiaoyu on 12-12-1.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "Reminder.h"
#import "BilateralFriend.h"
#import "ReminderManager.h"
#import "UserManager.h"
#import "LMLibrary.h"
#import "JTTableViewGestureRecognizer.h"

typedef enum {
    AudioStateNormal = 0,
    AudioStateDownload,
    AudioStatePlaying
}AudioState;

typedef enum {
    DataTypeCollectingBox = 0,
    DataTypeToday = 1,
    DataTypeRecent = 2,
    DataTypeHistory
}DataType;

typedef enum {
    CellEditingStateDefault = 0,
    CellEditingStateDelete = 1
}CellEditingState;

typedef enum {
    CellBackgroundImageViewTagFinish = 1,
    CellBackgroundImageViewTagDelete = 2
}CellBackgroundImageViewTag;

#define kLabelDescChangedY 20
#define kLabelDescOriY 20
#define kLabelDescOriX 42
#define kAudioButtonWidth  40
#define kNickNameLabelOriX 65
#define kNickNameLabelChangedX 65
#define kFinishButtonWidth 26

@protocol ReminderCellDelegate <NSObject>

@optional
- (void)clickAudioButton:(NSIndexPath *)indexPath withReminder:(Reminder *)reminder;
- (void)clickMapButton:(NSIndexPath *)indexPath withReminder:(Reminder *)reminder;
- (void)clickFinishButton:(NSIndexPath *)indexPath withReminder:(Reminder *)reminder;
@end

@interface ReminderBaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet EGOImageView * image;
@property (weak, nonatomic) IBOutlet UILabel * labelDescription;
@property (weak, nonatomic) IBOutlet UILabel * labelTriggerDate;
@property (weak, nonatomic) IBOutlet UIButton * btnAudio;
@property (weak, nonatomic) IBOutlet UIButton * btnMap;
@property (weak, nonatomic) IBOutlet UILabel * labelAddress;
@property (weak, nonatomic) IBOutlet UILabel * labelNickname;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * indicatorView;
@property (weak, nonatomic) IBOutlet UILabel * labelSendDate;
@property (weak, nonatomic) IBOutlet UILabel * labelAudioTime;
@property (weak, nonatomic) IBOutlet UIButton * btnFinished;
@property (weak, nonatomic) IBOutlet UILabel * labelDay;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewVoice;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewContact;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSeperator;

@property (weak, nonatomic) Reminder * reminder;
@property (weak, nonatomic) BilateralFriend * bilateralFriend;
@property (nonatomic) DataType dateType;
@property (strong, nonatomic) NSIndexPath * indexPath;
@property (nonatomic) AudioState audioState;
@property (nonatomic) CellEditingState editingState;
@property (weak, nonatomic) NSString * oneDay;
@property (weak, nonatomic) NSString * triggerTime;
@property (nonatomic) CGFloat imageViewContactOriX;

@property (weak, nonatomic) id<ReminderCellDelegate> delegate;

- (IBAction)palyAudio:(UIButton *)sender;
- (IBAction)showMap:(UIButton *)sender;
- (IBAction)finish:(UIButton *)sender;

- (void)modifyReminderReadState;
- (NSString *)custumDayString:(NSDate *)date;
- (BOOL)isAudioReminder;
- (BOOL)showFrom;
- (void)setViewWithGestureState:(JTTableViewCellEditingState)state withTranslation:(CGPoint)translation;
- (void)restoreView;
- (void)deleteFailed;

@end
