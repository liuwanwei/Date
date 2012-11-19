//
//  SoundManager.h
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundManager : NSObject

@property (strong, nonatomic) NSURL * recordFileURL;

+ (SoundManager *)defaultSoundManager;

- (BOOL)startRecord;
- (void)stopRecord;

@end
