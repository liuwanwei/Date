//
//  RemindersBaseViewController.m
//  date
//
//  Created by maoyu on 12-12-1.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "RemindersBaseViewController.h"
#import "ReminderDetailViewController.h"
#import "ReminderSettingViewController.h"
#import "AppDelegate.h"

@interface RemindersBaseViewController () {
    SoundManager * _soundManager;
}

@end

@implementation RemindersBaseViewController
@synthesize tableView = _tableView;
@synthesize reminderManager = _reminderManager;
@synthesize reminders = _reminders;

#pragma 私有函数
- (void)stopPlayingAudio {
    [_soundManager stopAudio];
    ReminderBaseCell * cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:_curIndexPath];
    cell.audioState = AudioStateNormal;
}

- (void)handleDownloadAudioFileResponse:(Reminder *)reminder withResult:(BOOL)result {
    if (nil != _curReminder && nil != _curIndexPath) {
        [self stopPlayingAudio];
        ReminderBaseCell * cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:_curIndexPath];
        if (YES == result) {
            [cell palyAudio:nil];
        }
    }
}

#pragma 类成员函数
- (NSString *)custumDateString:(NSString *)date {
    NSString * dateString;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    
    NSDate * nowDate = [NSDate date];
    nowDate = [formatter dateFromString:[formatter stringFromDate:nowDate]];
    NSDate * startDate = [formatter dateFromString:date];
    NSCalendar * calendar = [NSCalendar currentCalendar];

    NSUInteger unitFlags = NSDayCalendarUnit;
    
    //取相距时间额
    NSDateComponents * cps = [calendar components:unitFlags fromDate:nowDate  toDate:startDate  options:0];
    NSInteger diffDay  = [cps day];
    if (diffDay == 0) {
        dateString = @"今天";
    }else if (diffDay == 1) {
        dateString = @"明天";
    }else {
        dateString = date;
    }
    return dateString;
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
    self.tableView.rowHeight = 60.0;
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

/*- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _reminders.count;
}*/

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderBaseCell * cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    ReminderSettingViewController * controller = [[ReminderSettingViewController alloc] initWithNibName:@"ReminderSettingViewController" bundle:nil];
    controller.reminder = cell.reminder;
    controller.settingMode = SettingModeModify;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - SoundManager Delegate
- (void)audioPlayerDidFinishPlaying {
    [self stopPlayingAudio];
}

#pragma mark - FriendReminderCell Delegate
- (void)clickAudioButton:(NSIndexPath *)indexPath withReminder:(Reminder *)reminder {
    if (nil != _curIndexPath && _curIndexPath != indexPath) {
        [self stopPlayingAudio];
    }
    _curIndexPath = indexPath;
    _curReminder = reminder;
}

- (void)clickMapButton:(NSIndexPath *)indexPath withReminder:reminder{
    
    ReminderMapViewController * controller = [[ReminderMapViewController alloc] initWithNibName:@"ReminderMapViewController" bundle:nil];
    controller.reminder = reminder;
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
    if (nil != _curIndexPath) {
        ReminderBaseCell * cell = (ReminderBaseCell *)[self.tableView cellForRowAtIndexPath:_curIndexPath];
        [cell modifyReminderReadState];
    }
}

@end
