//
//  RemindersBaseViewController.m
//  date
//
//  Created by maoyu on 12-12-1.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "RemindersBaseViewController.h"
#import "ReminderMapViewController.h"

@interface RemindersBaseViewController () {
    SoundManager * _soundManager;
}

@end

@implementation RemindersBaseViewController
@synthesize tableView = _tableView;
@synthesize reminderManager = _reminderManager;
@synthesize reminders = _reminders;
@synthesize remindersAudioState = _remindersAudioState;

#pragma 私有函数

- (NSIndexPath *)indexPathOfAudioPlaying {
    if (nil != _remindersAudioState) {
        NSInteger size = _remindersAudioState.count;
        for (NSInteger index = 0; index < size; index++) {
            if ([NSNumber numberWithInteger:AudioStatePlaying] == [_remindersAudioState objectAtIndex:index]) {
                return [NSIndexPath indexPathForRow:index inSection:0];
            }
        }
    }
    
    return nil;
}

- (void)stopPlayingAudio {
    NSIndexPath * indexPath = [self indexPathOfAudioPlaying];
    ReminderBaseCell * cell;
    if (nil != indexPath) {
        [_soundManager stopAudio];
        cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.audioState = AudioStateNormal;
        [_remindersAudioState replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:AudioStateNormal]];
    }
}

- (void)handleDownloadAudioFileResponse:(Reminder *)reminder withResult:(BOOL)result {
    NSIndexPath * indexPath;
    indexPath = [self indexPathWithReminder:reminder];
    if (nil != indexPath && nil != _remindersAudioState) {
        if (YES == result) {
            [self stopPlayingAudio];
        }
        
        if ([[_remindersAudioState objectAtIndex:indexPath.row] integerValue] == AudioStateDownload) {
            ReminderBaseCell * cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.audioState = AudioStatePlaying;
            [_remindersAudioState replaceObjectAtIndex:indexPath.row withObject: [NSNumber numberWithInteger:AudioStatePlaying]];
            if (YES == result) {
                [cell palyAudio:nil];
            }
        }
    }
}

#pragma 类成员函数
- (NSIndexPath *)indexPathWithReminder:(Reminder *)reminder {
    if (nil != _reminders) {
        NSInteger size = _reminders.count;
        Reminder * tmpReminder;
        for (NSInteger index = 0;index < size;index++) {
            tmpReminder = [_reminders objectAtIndex:index];
            if ([tmpReminder.id isEqualToString:reminder.id]) {
                return [NSIndexPath indexPathForRow:index inSection:0];
            }
        }
    }
    return nil;
}

#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _soundManager = [SoundManager defaultSoundManager];
        _reminderManager = [ReminderManager defaultManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    self.tableView.rowHeight = 100.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _soundManager.delegate = self;
    _reminderManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _soundManager.delegate  = nil;
    _reminderManager.delegate = nil;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _reminders.count;
}

#pragma mark - SoundManager Delegate
- (void)audioPlayerDidFinishPlaying {
    [self stopPlayingAudio];
}

#pragma mark - FriendReminderCell Delegate
- (void)clickAudioButton:(NSIndexPath *)indexPath WithState:(NSNumber *)state {
    [self stopPlayingAudio];
    [_remindersAudioState replaceObjectAtIndex:indexPath.row withObject:state];
}

- (void)clickMapButton:(NSIndexPath *)indexPath {
    ReminderMapViewController * controller = [[ReminderMapViewController alloc] initWithNibName:@"ReminderMapViewController" bundle:nil];
    controller.reminder = [_reminders objectAtIndex:indexPath.row];
    controller.type = MapOperateTypeShow;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - ReminderManager Delegate
- (void)downloadAudioFileSuccess:(Reminder *)reminder {
    if (nil != reminder) {
        [self handleDownloadAudioFileResponse:reminder withResult:YES];
    }
}

- (void)downloadAudioFileFailed:(Reminder *)reminder {
    if (nil != reminder) {
        [self handleDownloadAudioFileResponse:reminder withResult:NO];
    }
}

- (void)updateReminderReadStateSuccess:(Reminder *)reminder {
    NSIndexPath * indexPath;
    indexPath = [self indexPathWithReminder:reminder];
    if (nil != indexPath) {
        ReminderBaseCell * cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell modifyReminderReadState];
    }
}

@end
