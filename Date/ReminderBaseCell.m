//
//  ReminderBaseCell.m
//  date
//
//  Created by lixiaoyu on 12-12-1.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderBaseCell.h"
#import "SoundManager.h"

@interface ReminderBaseCell () {

}

@end

@implementation ReminderBaseCell

@synthesize btnAudio = _btnAudio;
@synthesize btnMap = _btnMap;
@synthesize image = _image;
@synthesize labelTriggerDate = _labelTriggerDate;
@synthesize audioState = _audioState;
@synthesize reminder = _reminder;
@synthesize bilateralFriend = _bilateralFriend;
@synthesize indexPath = _indexPath;
@synthesize labelAddress = _labelAddress;
@synthesize indicatorView = _indicatorView;
@synthesize labelSendDate = _labelSendDate;
@synthesize labelNickname = _labelNickname;
@synthesize labelAudioTime = _labelAudioTime;

- (void)setReminder:(Reminder *)reminer {
    if (nil != reminer) {
        _reminder = reminer;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        _labelTriggerDate.text =[formatter stringFromDate:reminer.triggerTime];
        
        if (nil == _reminder.longitude || [_reminder.longitude isEqualToString:@"0"]) {
            [_btnMap setHidden:YES];
        }else {
            [_btnMap setHidden:NO];
        }
        
        if ([_reminder.type integerValue] == ReminderTypeReceive) {
            if (nil != _bilateralFriend && nil != _bilateralFriend.imageUrl) {
                [_image setImageURL:[NSURL URLWithString:_bilateralFriend.imageUrl]];
            }
        }else  {
            [_image setImageURL:[NSURL URLWithString:[UserManager defaultManager].imageUrl]];
        }
        
        _labelAudioTime.text = [_reminder.audioTime stringValue];
        
        _labelNickname.text = _bilateralFriend.nickname;
    }
}

- (void)setBilateralFriend:(BilateralFriend *)bilateralFriend {
    if (nil != bilateralFriend) {
        _bilateralFriend = bilateralFriend;
    }
}

- (void)setAudioState:(AudioState)audioState {
    _audioState = audioState;
    if (_audioState == AudioStateNormal) {
        [_btnAudio setBackgroundImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
        [_indicatorView stopAnimating];
        [_indicatorView setHidden:YES];
    }else if (_audioState == AudioStateDownload){
        [_indicatorView setHidden:NO];
        [_indicatorView startAnimating];
        [_btnAudio setHidden:YES];
    }else if (_audioState == AudioStatePlaying) {
        [_btnAudio setHidden:NO];
         [_btnAudio setBackgroundImage:[UIImage imageNamed:@"btnPause"] forState:UIControlStateNormal];
        [_indicatorView stopAnimating];
        [_indicatorView setHidden:YES];
    }
    
}

- (void)modifyReminderReadState {
    
}

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
    if (self.delegate != nil && nil != sender) {
        if ([self.delegate respondsToSelector:@selector(clickAudioButton: withReminder:)]) {
            [self.delegate performSelector:@selector(clickAudioButton: withReminder:) withObject:_indexPath withObject:_reminder];
        }
    }
    
    if (_audioState == AudioStatePlaying) {
        [[SoundManager defaultSoundManager] stopAudio];
        [self setAudioState:AudioStateNormal];
    }else {
        if (NO == [_reminder.isRead integerValue]) {
            [[ReminderManager defaultManager] updateReminderReadStateRequest:_reminder withReadState:YES];
        }
        
        if ([[SoundManager defaultSoundManager] fileExistsAtPath:_reminder.audioUrl]) {
            [self setAudioState:AudioStatePlaying];
            self.labelAudioTime.text = [_reminder.audioTime stringValue];
        }else {
            [self setAudioState:AudioStateDownload];
        }
        
        if (_audioState == AudioStatePlaying) {
            [[SoundManager defaultSoundManager] playAudio:_reminder.audioUrl];
        }else {
            [[ReminderManager defaultManager] downloadAudioFileWithReminder:_reminder];
        }
    }
}

- (IBAction)showMap:(UIButton *)sender {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(clickMapButton: withReminder:)]) {
            [self.delegate performSelector:@selector(clickMapButton: withReminder:) withObject:_indexPath withObject:_reminder];
        }
    }
}

@end
