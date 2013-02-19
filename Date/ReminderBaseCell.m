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
@synthesize labelDay = _labelDay;
@synthesize dateType = _dateType;
@synthesize editingState = _editingState;
@synthesize labelDescOriwidth = _labelDescOriwidth;
@synthesize imageViewAlarm = _imageViewAlarm;
@synthesize imageViewVoice = _imageViewVoice;
@synthesize imageViewContact = _imageViewContact;
@synthesize imageViewSeperator = _imageViewSeperator;

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
        dateString = @"睡觉前";
    }else if (diffDay > -7 && diffDay <= -1) {
        dateString = [NSString stringWithFormat:@"%d天前",diffDay * -1];
    }else {
        [formatter setDateFormat:@"MM-dd"];
        dateString = [dateString stringByAppendingString:[formatter stringFromDate:date]];
    }
    return dateString;
}

- (BOOL)isAudioReminder{
    if (nil == _reminder.audioUrl || [_reminder.audioUrl isEqualToString:@""]){
        return NO;
    }else{
        return YES;
    }
}

- (UIColor *)ongoingColor{
    return RGBColor(61, 145, 255);
}

- (UIColor *)passedColor{
    return RGBColor(153, 153, 153);
}

- (void)setReminder:(Reminder *)reminder {
    if (nil != reminder) {
        NSInteger offset = 0;
        _reminder = reminder;
        NSString * day;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        if (nil != reminder.triggerTime) {
            NSString * triggerTime = [formatter stringFromDate:self.reminder.triggerTime];
            day = [self custumDayString:self.reminder.triggerTime];
            if ([@"睡觉前" isEqualToString:day]) {
                [_imageViewAlarm setHidden:NO];
                [self.labelTriggerDate setHidden:NO];
                self.labelTriggerDate.text = triggerTime;
            }else {
                offset = 75;
                [self.labelTriggerDate setHidden:YES];
            }
            
            if (ReminderTypeReceiveAndNoAlarm == [reminder.type integerValue]) {
                offset = 75;
                [_imageViewAlarm setHidden:YES];
                [_labelTriggerDate setHidden:YES];
            }

        }else {
            if (nil != self.reminder.createTime) {
                 day = [self custumDayString:self.reminder.createTime];
            }
           
            offset = 75;
            [_imageViewAlarm setHidden:YES];
            [_labelTriggerDate setHidden:YES];
        }
        
        if ([self isAudioReminder]) {
            [_imageViewVoice setHidden:NO];
            [_labelAudioTime setHidden:NO];
            _imageViewVoice.frame = CGRectMake(130 - offset, 7 , 16, 16);
            _labelAudioTime.text = [[_reminder.audioLength stringValue] stringByAppendingString:@"''"];
        }else {
            offset = offset + 20;
            _imageViewVoice.frame = CGRectMake(130, 7 , 16, 16);
            [_imageViewVoice setHidden:YES];
            [_labelAudioTime setHidden:YES];
        }
        
        if ([[UserManager defaultManager] isOneself:[_reminder.userID stringValue]]) {
            [_imageViewContact setHidden:YES];
            _imageViewContact.frame = CGRectMake(150 - offset, 7 , 16, 16);
        }else {
            [_imageViewContact setHidden:NO];
            _imageViewVoice.frame = CGRectMake(150, 7 , 16, 16);
        }
        
        if (nil != self.reminder.triggerTime) {
            self.labelTriggerDate.textColor = [self ongoingColor];
        }

        _labelDescription.text = _reminder.desc;
        self.labelDay.text = day;
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

- (void)setEditingState:(CellEditingState)editingState{
    if ([self isAudioReminder]) {
        BOOL hidden = NO;
        if(CellEditingStateDelete == editingState){
            // 进入删除状态时隐藏播放按钮。
            hidden = YES;
        }
        
        self.btnAudio.hidden = hidden;
        self.labelAudioTime.hidden = hidden;
    }
}

- (BOOL)showFrom {
    NSString * from = @"来自:";
    BOOL result = NO;
    if (![[UserManager defaultManager] isOneself:[_reminder.userID stringValue]]) {
        result = YES;
        if (nil != _bilateralFriend) {
            from = [from stringByAppendingString:_bilateralFriend.nickname];
        }else {
            from = [from stringByAppendingString:[_reminder.userID stringValue]];
        }
    }
    
    if (YES == result) {
        _labelNickname.text = from;
        [_labelNickname setHidden:NO];
    }else {
        [_labelNickname setHidden:YES];
    }
    
    return result;
}

- (void)restoreView {
    UIImageView * imageViewFinsh = (UIImageView *)[self.backgroundView viewWithTag:CellBackgroundImageViewTagFinish];
    UIImageView * imageViewDelete = (UIImageView *)[self.backgroundView viewWithTag:CellBackgroundImageViewTagDelete];
    
    [imageViewFinsh setAlpha:0.5];
    imageViewFinsh.frame = CGRectMake(20, imageViewFinsh.frame.origin.y, imageViewFinsh.frame.size.width, imageViewFinsh.frame.size.height);
    [imageViewDelete setAlpha:0.5];
     imageViewDelete.frame = CGRectMake(280, imageViewDelete.frame.origin.y, imageViewDelete.frame.size.width, imageViewDelete.frame.size.height);
    self.labelDay.textColor = RGBColor(197, 73, 6);
    self.labelDescription.textColor = [UIColor blackColor];
    self.labelNickname.textColor = RGBColor(9, 84, 181);
    self.labelTriggerDate.textColor = [self ongoingColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)deleteFailed {
    [UIView beginAnimations:@"" context:nil];
    self.contentView.frame = self.contentView.bounds;
    [UIView commitAnimations];

}

- (void)setViewWithGestureState:(JTTableViewCellEditingState)state withTranslation:(CGPoint)translation {
    UIImageView * imageViewFinsh = (UIImageView *)[self.backgroundView viewWithTag:CellBackgroundImageViewTagFinish];
    UIImageView * imageViewDelete = (UIImageView *)[self.backgroundView viewWithTag:CellBackgroundImageViewTagDelete];
    
    UIColor * backgroundColor = [UIColor whiteColor];
    switch (state) {
        case JTTableViewCellEditingStateMiddle:
            [self restoreView];
            break;
        case JTTableViewCellEditingStateRight:
            [imageViewFinsh setAlpha:1];
            imageViewFinsh.frame = CGRectMake(20 + translation.x - 61, imageViewFinsh.frame.origin.y, imageViewFinsh.frame.size.width, imageViewFinsh.frame.size.height);
            backgroundColor = RGBColor(14, 170, 20);
            self.labelDay.textColor = [UIColor whiteColor];
            self.labelNickname.textColor = [UIColor whiteColor];
            self.labelTriggerDate.textColor = [UIColor whiteColor];
            self.labelDescription.textColor = [UIColor whiteColor];
            break;
        default:
            [imageViewDelete setAlpha:1];
            imageViewDelete.frame = CGRectMake(280 + translation.x + 61, imageViewDelete.frame.origin.y, imageViewDelete.frame.size.width, imageViewDelete.frame.size.height);
            break;
    }
    self.contentView.backgroundColor = backgroundColor;

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
    [self.btnFinished setHighlighted:NO];
    [self.btnFinished setSelected:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self.btnFinished setHighlighted:NO];
    [self.btnAudio setHighlighted:NO];
    [self.labelAudioTime setHighlighted:NO];
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
