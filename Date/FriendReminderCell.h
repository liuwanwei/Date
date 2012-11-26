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

@interface FriendReminderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet EGOImageView * image;
@property (weak, nonatomic) IBOutlet UILabel * labelTriggerDate;
@property (weak, nonatomic) IBOutlet UIButton * btnAudio;
@property (weak, nonatomic) IBOutlet UIButton * btnMap;
@property (weak, nonatomic) IBOutlet UIButton * btnClock;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * indicatorView;

@property (nonatomic) AudioState audioState;
@property (weak, nonatomic) Reminder * reminer;
@property (weak, nonatomic) BilateralFriend * bilateralFriend;

- (IBAction)palyAudio:(UIButton *)sender;
@end
