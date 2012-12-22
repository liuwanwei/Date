//
//  SoundManager.m
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "SoundManager.h"
#import "DocumentManager.h"

static SoundManager * sSoundManager;

@interface SoundManager () {
    AVAudioRecorder * _recorder;
    AVAudioPlayer * _player;
    NSDate * _startRecordDate;
    NSInteger _recordLength;
    NSTimer * _timer;
}

@end

@implementation SoundManager
@synthesize recordFileURL = _recordFileURL;
@synthesize view = _view;
@synthesize imageView = _imageView;
@synthesize viewWarning = _viewWarning;
@synthesize currentRecordTime = _currentRecordTime;
@synthesize parentView = _parentView;

+ (SoundManager *)defaultSoundManager {
    if (nil == sSoundManager) {
        sSoundManager = [[SoundManager alloc] init];
    }
    
    return sSoundManager;
}

- (id)init {
    if (self = [super init]) {
        [[NSBundle mainBundle] loadNibNamed:@"RecordView" owner:self options:nil];
        if (nil != _view) {
            _view.layer.masksToBounds = NO;
            _view.layer.cornerRadius = 8.0f;
            _viewWarning.layer.masksToBounds = NO;
            _viewWarning.layer.cornerRadius = 8.0f;
            [self initImageView];
        }
    }
    
    return self;
}

#pragma 私有函数
- (NSDictionary *)setting {
    NSMutableDictionary * recordSettings = [[NSMutableDictionary alloc] initWithCapacity:0];
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];//格式
    [recordSettings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey]; //采样8000次
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];//声道
    [recordSettings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];//位深度
    [recordSettings setValue :[NSNumber numberWithInt: AVAudioQualityMax]     forKey:AVEncoderAudioQualityKey];
    
    return recordSettings;
}

- (void)initImageView {
    if (nil != _imageView) {
        self.imageView.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"recordingSignal001"],
                                          [UIImage imageNamed:@"recordingSignal002"],
                                          [UIImage imageNamed:@"recordingSignal003"],
                                          [UIImage imageNamed:@"recordingSignal004"],
                                          [UIImage imageNamed:@"recordingSignal005"],
                                          [UIImage imageNamed:@"recordingSignal006"],
                                          [UIImage imageNamed:@"recordingSignal007"],
                                          [UIImage imageNamed:@"recordingSignal008"],
                                          nil];
        self.imageView.animationDuration = 1;
    }
}

- (void)showWaringView {
    if (nil != _parentView) {
        _viewWarning.frame = CGRectMake(50.0, 150.0, _viewWarning.frame.size.width,_viewWarning.frame.size.height);
        [_parentView addSubview:_viewWarning];
        
        [self performSelector:@selector(closeWaringView) withObject:self afterDelay:0.5];
    }
}

- (void)closeWaringView {
    [_viewWarning removeFromSuperview];
}

- (void)showRecordingView {
    if (nil != _parentView) {
        [_imageView startAnimating];
        _view.frame = CGRectMake(50.0, 100.0, _view.frame.size.width,_view.frame.size.height);
        [_parentView addSubview:_view];
    }
}

- (void)closeRecordingView {
    [_imageView stopAnimating];
    [_view removeFromSuperview];
}

- (NSString *)fileNameWithPath:(NSString *)path {
    NSString * fileName;
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    fileName = [path substringFromIndex:range.location + 1];
    return fileName;
}

- (void)checkRecordLength {
    if (_recordLength > 30) {
        [self stopTimer];
        [self stopRecord];
    }
    
    _recordLength++;
}

- (void)startTimer {
    [self stopTimer];
    _recordLength = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkRecordLength) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (nil != _timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma 类成员函数
- (BOOL)startRecord {
    BOOL result = NO;
    DocumentManager * manager = [DocumentManager defaultManager];
    _recordFileURL =  [manager pathForRandomSoundWithSuffix:@"m4a"];
    
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError * error;
    
    [session setCategory:AVAudioSessionCategoryRecord error:&error];
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return NO;
    }else {
        [session setActive:YES error:nil];
    }
    
    if (nil != _recorder) {
        [_recorder deleteRecording];
    }
        
    _recorder = [[AVAudioRecorder alloc] initWithURL:_recordFileURL settings:[self setting] error:&error];
    _startRecordDate = [NSDate date];
    [self showRecordingView];
    if(_recorder) {
        result = YES;
        [self startTimer];
        [_recorder record];
    }
    else {
        NSLog(@"recorder: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
    }
    
    return result;
}

- (BOOL)stopRecord {
    BOOL result = NO;
    [self stopTimer];
    if (nil != _recorder) {
        NSDate * endRecordDate = [NSDate date];
        [self closeRecordingView];
        NSTimeInterval diffTime = [endRecordDate timeIntervalSinceDate:_startRecordDate];
        if (diffTime < 0.5) {
            [_recorder stop];
            [_recorder deleteRecording];
            _recorder = nil;
            [self showWaringView];
        }else {
            result = YES;
            _currentRecordTime = _recorder.currentTime + 1;
            [self performSelector:@selector(realStopReocrd) withObject:self afterDelay:1.0];
        }
    }else {
        result = YES;
    }
    
    return result;
}

- (void)realStopReocrd {
    [_recorder stop];
    _recorder = nil;
}

- (BOOL)playRecording {
    BOOL result = NO;
    NSError * error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return NO;
    }else {
        [session setActive:YES error:nil];
    }
            
    _player  = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordFileURL error:&error];
    _player.numberOfLoops  = 0;
    _player.volume = 1.0;
    _player.delegate = self;
    if (nil == _player) {
        NSLog(@"播放失败");
    }else {
        result = YES;
        [_player prepareToPlay];
        [_player  play];
    }
    
    return result;
}

- (BOOL)playAudio:(NSString *)path {
    BOOL result = NO;
    NSError * error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return NO;
    }else {
        [session setActive:YES error:nil];
    }
    
    DocumentManager * manager = [DocumentManager defaultManager];
    
    path = [[manager soundPath] stringByAppendingPathComponent:[self fileNameWithPath:path]];
    NSURL * url = [NSURL fileURLWithPath:path isDirectory:NO];
    _player  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _player.numberOfLoops  = 0;
    _player.volume = 1.0;
    _player.delegate = self;
    if (nil == _player) {
        NSLog(@"播放失败 %@",[error localizedFailureReason]);
    }else {
        result = YES;
        [_player prepareToPlay];
        [_player  play];
    }
    
    return result;
}

- (void)stopAudio {
    if (nil != _player) {
        [_player stop];
        _player = nil;
    }
}

- (NSInteger)audioTime:(NSString *)path {
    NSInteger time = 0;
    NSError * error;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if(session == nil) {
        NSLog(@"Error creating session: %@", [error description]);
        return NO;
    }else {
        [session setActive:YES error:nil];
    }
    
    NSURL * url = [NSURL fileURLWithPath:path isDirectory:NO];
    _player  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (nil != _player) {
        time = _player.duration;
    }
    
    return time;
}

- (BOOL)fileExistsAtPath:(NSString *)path {
    DocumentManager * manager = [DocumentManager defaultManager];
    path = [[manager soundPath] stringByAppendingPathComponent:[self fileNameWithPath:path]];
    if (YES == [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    
    return NO;
}

#pragma AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    _player = nil;
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying)]) {
            [self.delegate performSelector:@selector(audioPlayerDidFinishPlaying) withObject:nil];
        }
    }

}

@end
