//
//  SoundManager.h
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    VoiceTypeAlarm = 0,
    VoiceTypeReminder
}VoiceType;

#define AlertSoundKey               @"AlertSoundKey"
#define AlertSoundTypeSilence       @"AlertSoundTypeSilence"
#define AlertSoundTypeCat           @"milkCat.wav"
#define AlertSoundTypeDog           @"bigDog.wav"
#define AlertSoundTypeNightingale   @"nightingale.wav"

#define AlertSoundTitleCat           @"喵星人"
#define AlertSoundTitleDog           @"汪星人"
#define AlertSoundTitleNightingale   @"夜莺"
#define AlertSoundTitleSilence       @"静音"

@protocol SoundManagerDelegate <NSObject>

@optional
- (void)alarmPlayerDidFinishPlaying;
- (void)audioPlayerDidFinishPlaying;
- (void)audioPlayerDidStopPlaying;
@end

@interface SoundManager : NSObject <AVAudioPlayerDelegate,AVAudioRecorderDelegate>

@property (strong, nonatomic) NSURL * recordFileURL;
@property (strong, nonatomic) IBOutlet UIView * view;
@property (weak, nonatomic) IBOutlet UIImageView * imageView;
@property (strong, nonatomic) IBOutlet UIView * viewWarning;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * indicatorView;
@property (weak, nonatomic) UIView * parentView;
@property (nonatomic) NSTimeInterval currentRecordTime;
@property (nonatomic, strong) NSArray * aviableAlertSounds;
@property (nonatomic, strong) NSString * alertSound;

@property (weak, nonatomic) id<SoundManagerDelegate> delegate;

+ (SoundManager *)defaultSoundManager;

- (BOOL)startRecord;
- (BOOL)stopRecord;

- (BOOL)playRecording;

- (BOOL)playAudio:(NSString *)path;
- (void)stopAudio;
- (void)deleteAudioFile:(NSString *)path;

- (void)playAlarmVoice;
- (void)playAlertSound:(NSString *)bundleSoundName;
- (void)saveAlertSound:(NSString *)sound;
- (NSString *)alertSoundTitleForType:(NSString *)type;

- (NSInteger)audioTime:(NSString *)path;

- (BOOL)fileExistsAtPath:(NSString *)path;

- (NSString *)createDefaultAudio:(NSInteger)index;
@end
