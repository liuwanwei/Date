//
//  ReminderBaseCell.m
//  date
//
//  Created by lixiaoyu on 12-12-1.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderBaseCell.h"
#import "SoundManager.h"
#import "LMLibrary.h"

#define LeftMargin  13
#define LabelDesOffset 18
#define LabelDesY 42

@interface ReminderBaseCell () {

}

@end

@implementation ReminderBaseCell

@synthesize labelDescription = _labelDescription;
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
@synthesize btnFinished = _btnFinished;
@synthesize showFrom = _showFrom;
@synthesize labelDay = _labelDay;
@synthesize showDay = _showDay;
@synthesize dateType = _dateType;

- (NSString *)custumDayString:(NSDate *)date {
    NSString * dateString = @"" ;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate * nowDate = [NSDate date];
    nowDate = [formatter dateFromString:[formatter stringFromDate:nowDate]];
    date = [formatter dateFromString:[formatter stringFromDate:date]];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSDayCalendarUnit;
    
    //取相距时间额
    NSDateComponents * cps = [calendar components:unitFlags fromDate:nowDate  toDate:date  options:0];
    NSInteger diffDay  = [cps day];
    if (diffDay == 0) {
        dateString = @"";
    }else if (diffDay == 1) {
        dateString = @"";
    }else if (diffDay == 2) {
        dateString = @"";
    }else if (diffDay == -1) {
        dateString = @"(昨天) ";
    }else {
        [formatter setDateFormat:@"MM-dd"];
        dateString = [dateString stringByAppendingString:@"("];
        dateString = [dateString stringByAppendingString:[formatter stringFromDate:date]];
        dateString = [dateString stringByAppendingString:@")"];
    }
    return dateString;
}

- (void)setReminder:(Reminder *)reminer {
    if (nil != reminer) {
        _reminder = reminer;
        if (_dateType == DataTypeCollectingBox) {
            [_labelTriggerDate setHidden:YES];
            [_labelDay setHidden:YES];
            [_labelNickname setHidden:YES];
            _labelDescription.frame = CGRectMake(_labelDescription.frame.origin.x, LabelDesY - LabelDesOffset, _labelDescription.frame.size.width, _labelDescription.frame.size.height);
        }else {
            [_labelTriggerDate setHidden:NO];
            [_labelDay setHidden:NO];
            [_labelNickname setHidden:NO];
            _labelDescription.frame = CGRectMake(_labelDescription.frame.origin.x, LabelDesY, _labelDescription.frame.size.width, _labelDescription.frame.size.height);
        }
        if (nil == _reminder.longitude || [_reminder.longitude isEqualToString:@"0"]) {
            [_btnMap setHidden:YES];
        }else {
            [_btnMap setHidden:NO];
        }
        
        if (YES == _showFrom) {
            NSString * from = @"来自:";
            if ([[UserManager defaultManager] isOneself:[_reminder.userID stringValue]]) {
//                from = [from stringByAppendingString:@"我"];
                from = @"";
            }else if (nil != _bilateralFriend) {
                from = [from stringByAppendingString:_bilateralFriend.nickname];
            }else {
                from = [from stringByAppendingString:[_reminder.userID stringValue]];
            }
            
            _labelNickname.text = from;
            [_labelNickname setHidden:NO];
        }else {
            [_labelNickname setHidden:YES];
        }
        
        if (NO == _showDay) {
            _labelTriggerDate.frame = CGRectMake(LeftMargin, _labelTriggerDate.frame.origin.y, _labelTriggerDate.frame.size.width, _labelTriggerDate.frame.size.height);
            _labelDay.frame = CGRectMake(_labelDay.frame.origin.x, _labelDay.frame.origin.y, 0, _labelDay.frame.size.height);
            _labelNickname.frame = CGRectMake(74, _labelNickname.frame.origin.y, _labelNickname.frame.size.width, _labelNickname.frame.size.height);
            _labelDescription.frame =  CGRectMake(LeftMargin, _labelDescription.frame.origin.y, _labelDescription.frame.size.width, _labelDescription.frame.size.height);

        }else {
            _labelTriggerDate.frame = CGRectMake(42, _labelTriggerDate.frame.origin.y, _labelTriggerDate.frame.size.width, _labelTriggerDate.frame.size.height);
            _labelDescription.frame =  CGRectMake(45, _labelDescription.frame.origin.y, _labelDescription.frame.size.width, _labelDescription.frame.size.height);
            if (nil != reminer.triggerTime) {
                NSString * day;
                if (DataTypeRecent == _dateType) {
                    day = @"";
                }else {
                    day = [self custumDayString:reminer.triggerTime];
                }
               
                if ([day isEqualToString:@""]) {
                    _labelDay.frame = CGRectMake(100, _labelDay.frame.origin.y, 0, _labelDay.frame.size.height);
                    _labelNickname.frame = CGRectMake(_labelDay.frame.origin.x, _labelNickname.frame.origin.y, _labelNickname.frame.size.width + 42, _labelNickname.frame.size.height);
                }else {
                    _labelDay.text = day;
                    _labelDay.frame = CGRectMake(100, _labelDay.frame.origin.y, 42, _labelDay.frame.size.height);
                    _labelNickname.frame = CGRectMake(_labelDay.frame.origin.x + 42, _labelNickname.frame.origin.y, _labelNickname.frame.size.width, _labelNickname.frame.size.height);
                }
            }else {
                _labelDay.frame = CGRectMake(_labelDay.frame.origin.x, _labelDay.frame.origin.y, 0, _labelDay.frame.size.height);
                _labelNickname.frame = CGRectMake(_labelDay.frame.origin.x, _labelNickname.frame.origin.y, _labelNickname.frame.size.width + 42, _labelNickname.frame.size.height);
            }
        }
        
        
        if (nil == _reminder.audioUrl || [_reminder.audioUrl isEqualToString:@""]) {
            [_btnAudio setHidden:YES];
            [_labelAudioTime setHidden:YES];
            [_indicatorView setHidden:YES];
            _labelDescription.frame = CGRectMake(_labelDescription.frame.origin.x, _labelDescription.frame.origin.y, 235, _labelDescription.frame.size.height);

        }else {
            [_btnAudio setHidden:NO];
            [_labelAudioTime setHidden:NO];
            [_indicatorView setHidden:NO];
            _labelAudioTime.text = [_reminder.audioLength stringValue];
            _labelDescription.frame = CGRectMake(_labelDescription.frame.origin.x, _labelDescription.frame.origin.y, 185, _labelDescription.frame.size.height);
        }
        
        _labelDescription.text = _reminder.desc;
        
    }
}

- (void)setBilateralFriend:(BilateralFriend *)bilateralFriend {
    _bilateralFriend = bilateralFriend;
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

- (NSInteger)checkColor:(NSInteger)value{
    return value >= 255 ? 255 : value;
}

- (UIColor *)colorForRow:(NSInteger)row{
    NSInteger r = 230;
    NSInteger g = 236;
    NSInteger b = 240;
    NSInteger step = 5; // 亮度依次加2%。
    
    step = step * row;
    
    r += step;
    g += step;
    b += step;

    r = [self checkColor:r];
    g = [self checkColor:g];
    b = [self checkColor:b];
    
    
    return RGBColor(r, g, b);
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    
    _indexPath = indexPath;
    return;
    NSInteger index = indexPath.row;
    
    NSInteger type = 0;
    type = 1;
    if (type == 0) {
        static NSArray * sColorArray = nil;
        
        if (nil == sColorArray) {
            sColorArray = [[NSArray alloc] initWithObjects:
                           /*RGBColor(0xe0,0xd8,0xcd),
                            RGBColor(0xe5 , 0xdd, 0xd2),
                            RGBColor(0xff, 0xff, 0xff),*/
                           RGBColor(225, 231, 235),
                           RGBColor(235, 241, 245),nil];
            
        }
        index = index % 2;
        NSLog(@"%d",index);
        [self.contentView setBackgroundColor:[sColorArray objectAtIndex:index]];

    }else{
        [self.contentView setBackgroundColor:[self colorForRow:index]];
    }

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
        /*if (NO == [_reminder.isRead integerValue]) {
            [[ReminderManager defaultManager] updateReminderReadStateRequest:_reminder withReadState:YES];
        }*/
        
        if ([[SoundManager defaultSoundManager] fileExistsAtPath:_reminder.audioUrl]) {
            [self setAudioState:AudioStatePlaying];
            self.labelAudioTime.text = [_reminder.audioLength stringValue];
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

- (IBAction)finish:(UIButton *)sender {
    if ([_reminder.state integerValue] == ReminderStateUnFinish) {
        [[ReminderManager defaultManager] modifyReminder:_reminder withState:ReminderStateFinish];
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(clickFinishButton: withReminder:)]) {
                [self.delegate performSelector:@selector(clickFinishButton: withReminder:) withObject:_indexPath withObject:_reminder];
            }
        }
    }
}

@end
