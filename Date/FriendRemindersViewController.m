//
//  FriendRemindersViewController.m
//  Date
//
//  Created by maoyu on 12-11-23.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "FriendRemindersViewController.h"
#import "ReminderMapViewController.h"

typedef enum {
    ReminderTypeReceive = 0,
    ReminderTypeSend
}ReminderType;

@interface FriendRemindersViewController () {
    NSArray * _reminders;
    NSMutableArray * _ramindersAudioState;
    ReminderManager * _reminderManager;
    SoundManager * _soundManager;
}

@end

@implementation FriendRemindersViewController
@synthesize userId = _userId;
@synthesize tableView = _tableView;
@synthesize bilateralFriend = _bilateralFriend;

#pragma 私有函数
- (void)initData {
    _reminders = [_reminderManager remindersWithUserId:_userId];
    if (nil != _reminders) {
        _ramindersAudioState = [NSMutableArray arrayWithCapacity:0];
        NSInteger size = _reminders.count;
        for (NSInteger index = 0; index < size; index++) {
            [_ramindersAudioState addObject:[NSNumber numberWithInteger:AudioStateNormal]];
        }
        [self.tableView reloadData];
    }
}

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

- (NSIndexPath *)indexPathOfAudioPlaying {
    if (nil != _ramindersAudioState) {
        NSInteger size = _ramindersAudioState.count;
        for (NSInteger index = 0; index < size; index++) {
            if ([NSNumber numberWithInteger:AudioStatePlaying] == [_ramindersAudioState objectAtIndex:index]) {
                return [NSIndexPath indexPathForRow:index inSection:0];
            }
        }
    }
    
    return nil;
}

- (void)stopPlayingAudio {
    NSIndexPath * indexPath = [self indexPathOfAudioPlaying];
    FriendReminderCell * cell;
    if (nil != indexPath) {
        [_soundManager stopAudio];
        cell = (FriendReminderCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.audioState = AudioStateNormal;
        [_ramindersAudioState replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:AudioStateNormal]];
    }
}


#pragma 事件函数
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _reminderManager = [ReminderManager defaultManager];
        _soundManager = [SoundManager defaultSoundManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    self.tableView.rowHeight = 80.0;
    [self initData];
    self.title = _bilateralFriend.nickname;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _reminderManager.delegate = self;
    _soundManager.delegate  = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _reminderManager.delegate = nil;
    _soundManager.delegate  = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    FriendReminderCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FriendReminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    Reminder * reminder = [_reminders objectAtIndex:indexPath.row];
    cell.indexPath = indexPath;
    if (ReminderTypeSend == [reminder.type integerValue]) {
        cell.bilateralFriend = nil;
    }else {
        cell.bilateralFriend = _bilateralFriend;
    }
    
    cell.reminder = reminder;
    cell.audioState = [[_ramindersAudioState objectAtIndex:indexPath.row] integerValue];
    return cell;
}

#pragma mark - ReminderManager Delegate
- (void)downloadAudioFileSuccess:(Reminder *)reminder {
    if (nil != reminder) {
        [self stopPlayingAudio];
        NSIndexPath * indexPath;
        indexPath = [self indexPathWithReminder:reminder];
        if (nil != indexPath && nil != _ramindersAudioState) {
            if ([[_ramindersAudioState objectAtIndex:indexPath.row] integerValue] == AudioStateDownload) {
                FriendReminderCell * cell = (FriendReminderCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                cell.audioState = AudioStatePlaying;
                [_ramindersAudioState replaceObjectAtIndex:indexPath.row withObject: [NSNumber numberWithInteger:AudioStatePlaying]];
                [cell palyAudio:nil];
            }
        }
    }
}

- (void)updateReminderReadStateSuccess:(Reminder *)reminder {
    NSIndexPath * indexPath;
    indexPath = [self indexPathWithReminder:reminder];
    if (nil != indexPath) {
        FriendReminderCell * cell = (FriendReminderCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell modifyReminderReadState];
    }
}

#pragma mark - FriendReminderCell Delegate
- (void)clickAudioButton:(NSIndexPath *)indexPath WithState:(NSNumber *)state {
    [self stopPlayingAudio];
    [_ramindersAudioState replaceObjectAtIndex:indexPath.row withObject:state];
}

- (void)clickMapButton:(NSIndexPath *)indexPath {
    ReminderMapViewController * controller = [[ReminderMapViewController alloc] initWithNibName:@"ReminderMapViewController" bundle:nil];
    controller.reminder = [_reminders objectAtIndex:indexPath.row];
    controller.type = OperateTypeShow;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];

}

#pragma mark - SoundManager Delegate
- (void)audioPlayerDidFinishPlaying {
    [self stopPlayingAudio];
}

@end
