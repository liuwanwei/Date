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


@protocol SoundManagerDelegate <NSObject>

@optional
- (void)audioPlayerDidFinishPlaying;
- (void)audioPlayerDidStopPlaying;
@end

@interface SoundManager : NSObject <AVAudioPlayerDelegate>

@property (strong, nonatomic) NSURL * recordFileURL;
@property (strong, nonatomic) IBOutlet UIView * view;
@property (weak, nonatomic) IBOutlet UIImageView * imageView;
@property (weak, nonatomic) IBOutlet UIView * viewWarning;
@property (weak, nonatomic) UIView * parentView;

@property (weak, nonatomic) id<SoundManagerDelegate> delegate;

+ (SoundManager *)defaultSoundManager;

- (BOOL)startRecord;
- (BOOL)stopRecord;

- (BOOL)playRecording;

- (BOOL)playAudio:(NSString *)path;
- (void)stopAudio;

- (NSInteger)audioTime:(NSString *)path;
@end
