//
//  FriendReminderCell.h
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "Reminder.h"
#import "BilateralFriend.h"

typedef enum {
    AudioStateNormal = 0,
    AudioStateDownload,
    AudioStatePlaying
}AudioState;

@protocol FriendReminderCellDelegate <NSObject>

@optional
- (void)clickAudioButton:(NSIndexPath *)indexPath WithState:(NSNumber *) state;
@end

@interface FriendReminderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet EGOImageView * image;
@property (weak, nonatomic) IBOutlet UILabel * labelTriggerDate;
@property (weak, nonatomic) IBOutlet UIButton * btnAudio;
@property (weak, nonatomic) IBOutlet UIButton * btnMap;
@property (weak, nonatomic) IBOutlet UIButton * btnClock;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * indicatorView;
@property (weak, nonatomic) IBOutlet UIButton * btnMark;
@property (weak, nonatomic) IBOutlet UILabel * labelAddress;

@property (weak, nonatomic) Reminder * reminer;
@property (weak, nonatomic) BilateralFriend * bilateralFriend;

@property (strong, nonatomic) NSIndexPath * indexPath;
@property (nonatomic) AudioState audioState;

@property (weak, nonatomic) id<FriendReminderCellDelegate> delegate;

- (IBAction)palyAudio:(UIButton *)sender;
- (IBAction)modifyBell:(UIButton *)sender;
@end
