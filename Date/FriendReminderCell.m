//
//  FriendReminderCell.m
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "FriendReminderCell.h"
#import "HttpRequestManager.h"

@implementation FriendReminderCell
@synthesize btnAudio = _btnAudio;
@synthesize btnClock = _btnClock;
@synthesize btnMap = _btnMap;
@synthesize image = _image;
@synthesize labelTriggerDate = _labelTriggerDate;
@synthesize indicatorView = _indicatorView;
@synthesize audioState = _audioState;
@synthesize reminer = _reminer;
@synthesize bilateralFriend = _bilateralFriend;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)palyAudio:(UIButton *)sender {
    if ([[NSFileManager defaultManager] fileExistsAtPath:_reminer.audioUrl]) {
        
    }else {
        
    }
}

- (void)setReminer:(Reminder *)reminer {
    if (nil != reminer) {
        _labelTriggerDate.text = [reminer.triggerTime description];
    }
}

- (void)setBilateralFriend:(BilateralFriend *)bilateralFriend {
    if (nil != bilateralFriend) {
        if (nil != bilateralFriend.imageUrl) {
            [_image setImageURL:[NSURL URLWithString:bilateralFriend.imageUrl]];
        }
    }
}

- (void)setAudioState:(AudioState)audioState {
    
}

@end
