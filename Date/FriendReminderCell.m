//
//  FriendReminderCell.m
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "FriendReminderCell.h"
#import "SoundManager.h"
#import "ReminderManager.h"

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
@synthesize indexPath = _indexPath;
@synthesize btnMark = _btnMark;
@synthesize labelAddress = _labelAddress;

#pragma 私有函数
- (void)modifyReminderReadState{
    if (nil == _reminer.isRead || NO == [_reminer.isRead integerValue]) {
        [[ReminderManager defaultManager] modifyReminder:_reminer withReadState:YES];
        if (YES == [_reminer.isRead integerValue]) {
            [_btnClock setHidden:NO];
            [_btnMark setHidden:YES];
        }
        [self modifyReminderBellState:YES];
    }
}

- (void)modifyReminderBellState:(BOOL)isBell {
    [[ReminderManager defaultManager] modifyReminder:_reminer withBellState:isBell];
    if (YES == [_reminer.isBell integerValue]) {
        [_btnClock setTitle:@"取消提醒" forState:UIControlStateNormal];
        [[ReminderManager defaultManager] addLocalNotificationWithReminder:_reminer];
    }else {
        [_btnClock setTitle:@"提醒" forState:UIControlStateNormal];
        [[ReminderManager defaultManager] cancelLocalNotificationWithReminder:_reminer];
    }
}

#pragma 事件函数
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"FriendReminderCell" owner:self options:nil] ;
        self = [nib objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)palyAudio:(UIButton *)sender {
    [self modifyReminderReadState];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_reminer.audioUrl]) {
        [self setAudioState:AudioStatePlaying];
        [[SoundManager defaultSoundManager] playAudio:_reminer.audioUrl];
        
    }else {
        [self setAudioState:AudioStateDownload];
        [[ReminderManager defaultManager] downloadAudioFileWithReminder:_reminer];
    }
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(clickAudioButton: WithState:)]) {
            [self.delegate performSelector:@selector(clickAudioButton: WithState:) withObject:_indexPath withObject:[NSNumber numberWithInteger:_audioState]];
        }
    }
}

- (IBAction)modifyBell:(UIButton *)sender {
    if (YES == [_reminer.isBell integerValue]) {
        [self modifyReminderBellState:NO];
    }else {
        [self modifyReminderBellState:YES];
    }
}

- (void)setReminer:(Reminder *)reminer {
    if (nil != reminer) {
        _reminer = reminer;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _labelTriggerDate.text = [formatter stringFromDate:reminer.triggerTime];
        if (nil != reminer.isRead && YES == [reminer.isRead integerValue]) {
            [_btnClock setHidden:NO];
            [_btnMark setHidden:YES];
        }else {
            [_btnClock setHidden:YES];
            [_btnMark setHidden:NO];
        }
        
        if (YES == [_reminer.isBell integerValue]) {
            [_btnClock setTitle:@"取消提醒" forState:UIControlStateNormal];
        }else {
            [_btnClock setTitle:@"提醒" forState:UIControlStateNormal];
        }

        if ([_reminer.longitude isEqualToString:@"0"] && [_reminer.latitude isEqualToString:@"0"]) {
            [_btnMap setHidden:YES];
            [_labelAddress setHidden:YES];
        }else {
            [_btnMap setHidden:NO];
            if (nil != _reminer.adress) {
                [_labelAddress setHidden:NO];
                _labelAddress.text = _reminer.adress;
            }else {
                [_labelAddress setHidden:YES];
            }
        }
    }
}

- (void)setBilateralFriend:(BilateralFriend *)bilateralFriend {
    if (nil != bilateralFriend) {
        _bilateralFriend = bilateralFriend;
        if (nil != bilateralFriend.imageUrl) {
            [_image setImageURL:[NSURL URLWithString:bilateralFriend.imageUrl]];
        }
    }
}

- (void)setAudioState:(AudioState)audioState {
    _audioState = audioState;
    if (_audioState == AudioStateNormal) {
        [_btnAudio setTitle:@"播放" forState:UIControlStateNormal];
        [_indicatorView stopAnimating];
        [_indicatorView setHidden:YES];
    }else if (_audioState == AudioStateDownload){
        [_indicatorView setHidden:NO];
        [_indicatorView startAnimating];
        [_btnAudio setHidden:YES];
    }else if (_audioState == AudioStatePlaying) {
        [_btnAudio setHidden:NO];
        [_btnAudio setTitle:@"暂停" forState:UIControlStateNormal];
        [_indicatorView stopAnimating];
        [_indicatorView setHidden:YES];
    }
}

@end
