//
//  SoundManager.m
//  Date
//
//  Created by maoyu on 12-11-16.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "SoundManager.h"

static SoundManager * sSoundManager;

@implementation SoundManager
@synthesize recordFileURL = _recordFileURL;

+ (SoundManager *)defaultSoundManager {
    if (nil == sSoundManager) {
        sSoundManager = [[SoundManager alloc] init];
    }
    
    return sSoundManager;
}

#pragma 类成员函数
- (BOOL)startRecord {
    BOOL result = NO;
    
    return result;
}

- (void)stopRecord {
    
}

@end
