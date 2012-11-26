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

@interface SoundManager : NSObject <AVAudioPlayerDelegate>

@property (strong, nonatomic) NSURL * recordFileURL;
@property (strong, nonatomic) IBOutlet UIView * view;
@property (weak, nonatomic) IBOutlet UIImageView * imageView;

+ (SoundManager *)defaultSoundManager;

- (BOOL)startRecord;
- (BOOL)stopRecord;

- (BOOL)playRecording;

@end
