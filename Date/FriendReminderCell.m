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
#import "UserManager.h"

@implementation FriendReminderCell
@synthesize btnAudio = _btnAudio;
@synthesize btnClock = _btnClock;
@synthesize btnMap = _btnMap;
@synthesize image = _image;
@synthesize labelTriggerDate = _labelTriggerDate;
@synthesize indicatorView = _indicatorView;
@synthesize audioState = _audioState;
@synthesize reminder = _reminder;
@synthesize bilateralFriend = _bilateralFriend;
@synthesize indexPath = _indexPath;
@synthesize btnMark = _btnMark;
@synthesize labelAddress = _labelAddress;

#pragma 私有函数
- (void)modifyReminderBellState:(BOOL)isBell {
    [[ReminderManager defaultManager] modifyReminder:_reminder withBellState:isBell];
    if (YES == [_reminder.isBell integerValue]) {
        [_btnClock setTitle:@"取消提醒" forState:UIControlStateNormal];
        [[ReminderManager defaultManager] addLocalNotificationWithReminder:_reminder withBilateralFriend:_bilateralFriend];
    }else {
        [_btnClock setTitle:@"提醒" forState:UIControlStateNormal];
        [[ReminderManager defaultManager] cancelLocalNotificationWithReminder:_reminder];
    }
}

#pragma 类成员函数
- (void)modifyReminderReadState{
    if (nil == _reminder.isRead || NO == [_reminder.isRead integerValue]) {
        [[ReminderManager defaultManager] modifyReminder:_reminder withReadState:YES];
        if (YES == [_reminder.isRead integerValue]) {
            [_btnClock setHidden:NO];
            [_btnMark setHidden:YES];
        }
        [self modifyReminderBellState:YES];
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
    if (NO == [_reminder.isRead integerValue]) {
        [[ReminderManager defaultManager] updateReminderReadStateRequest:_reminder withReadState:YES];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_reminder.audioUrl]) {
        [self setAudioState:AudioStatePlaying];
        [[SoundManager defaultSoundManager] playAudio:_reminder.audioUrl];
        
    }else {
        [self setAudioState:AudioStateDownload];
        [[ReminderManager defaultManager] downloadAudioFileWithReminder:_reminder];
    }
    
    if (self.delegate != nil && nil != sender) {
        if ([self.delegate respondsToSelector:@selector(clickAudioButton: WithState:)]) {
            [self.delegate performSelector:@selector(clickAudioButton: WithState:) withObject:_indexPath withObject:[NSNumber numberWithInteger:_audioState]];
        }
    }
}

- (IBAction)modifyBell:(UIButton *)sender {
    if (YES == [_reminder.isBell integerValue]) {
        [self modifyReminderBellState:NO];
    }else {
        [self modifyReminderBellState:YES];
    }
}

- (IBAction)showMap:(UIButton *)sender {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(clickMapButton:)]) {
            [self.delegate performSelector:@selector(clickMapButton:) withObject:_indexPath];
        }
    }
}

- (void)setReminder:(Reminder *)reminer {
    if (nil != reminer) {
        _reminder = reminer;
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
        
        if (YES == [_reminder.isBell integerValue]) {
            [_btnClock setTitle:@"取消提醒" forState:UIControlStateNormal];
        }else {
            [_btnClock setTitle:@"提醒" forState:UIControlStateNormal];
        }

        if (nil == _reminder.longitude || [_reminder.longitude isEqualToString:@"0"]) {
            [_btnMap setHidden:YES];
            [_labelAddress setHidden:YES];
        }else {
            [_btnMap setHidden:NO];
            if (nil != _reminder.adress) {
                [_labelAddress setHidden:NO];
                _labelAddress.text = _reminder.adress;
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
    }else {
        
        [_image setImageURL:[NSURL URLWithString:[UserManager defaultManager].imageUrl]];
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
