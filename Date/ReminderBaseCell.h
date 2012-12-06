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

typedef enum {
    AudioStateNormal = 0,
    AudioStateDownload,
    AudioStatePlaying
}AudioState;

@protocol ReminderCellDelegate <NSObject>

@optional
- (void)clickAudioButton:(NSIndexPath *)indexPath withReminder:(Reminder *)reminder;
- (void)clickMapButton:(NSIndexPath *)indexPath withReminder:(Reminder *)reminder;
@end

@interface ReminderBaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet EGOImageView * image;
@property (weak, nonatomic) IBOutlet UILabel * labelTriggerDate;
@property (weak, nonatomic) IBOutlet UIButton * btnAudio;
@property (weak, nonatomic) IBOutlet UIButton * btnMap;
@property (weak, nonatomic) IBOutlet UILabel * labelAddress;
@property (weak, nonatomic) IBOutlet UILabel * labelNickname;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * indicatorView;
@property (weak, nonatomic) IBOutlet UILabel * labelSendDate;
@property (weak, nonatomic) IBOutlet UILabel * labelAudioTime;

@property (weak, nonatomic) Reminder * reminder;
@property (weak, nonatomic) BilateralFriend * bilateralFriend;

@property (strong, nonatomic) NSIndexPath * indexPath;
@property (nonatomic) AudioState audioState;

@property (weak, nonatomic) id<ReminderCellDelegate> delegate;

- (IBAction)palyAudio:(UIButton *)sender;
- (IBAction)showMap:(UIButton *)sender;

- (void)modifyReminderReadState;
@end
