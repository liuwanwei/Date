//
//  ReminderDetailViewController.m
//  date
//
//  Created by maoyu on 12-12-6.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderDetailViewController.h"
#import "ReminderDetailAudioCell.h"
#import "AppDelegate.h"

@interface ReminderDetailViewController () {
    UIButton * _btnFinish;
    UIButton * _btnUnFinish;
}

@end

@implementation ReminderDetailViewController
@synthesize reminder = _reminder;
@synthesize friend = _friend;
@synthesize tableView = _tableView;
@synthesize detailViewShowMode = _detailViewShowMode;
@synthesize sections = _sections;
@synthesize dateFormatter = _dateFormatter;

#pragma 私有函数
- (void)modifyReminderState {
    [self.reminderManager modifyReminder:_reminder withState:ReminderStateFinish];
    [self dismiss];
}

- (void)initTableFooterView {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 100)];
    if (_detailViewShowMode == DeailViewShowModePresent) {
        _btnUnFinish = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _btnUnFinish.layer.frame = CGRectMake(50, 15, 100, 44);
        [_btnUnFinish setBackgroundImage:[UIImage imageNamed:@"buttonBg"] forState:UIControlStateNormal];
        [_btnUnFinish setTitle:@"稍候" forState:UIControlStateNormal];
        [_btnUnFinish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnUnFinish addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:_btnUnFinish];
    }
    
    _btnFinish = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnFinish.layer.frame = CGRectMake(170, 15, 100, 44);
    [_btnFinish setTitle:@"完成" forState:UIControlStateNormal];
    [_btnFinish setBackgroundImage:[UIImage imageNamed:@"buttonBg"] forState:UIControlStateNormal];
    [_btnFinish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnFinish addTarget:self action:@selector(modifyReminderState) forControlEvents:UIControlEventTouchUpInside];
    if (NO == [_reminder.isRead boolValue]) {
        [_btnFinish setHidden:YES];
    }
    [view addSubview:_btnFinish];
    
    self.tableView.tableFooterView = view;
}

- (void)checkRemindersExpired {
     [[AppDelegate delegate] checkRemindersExpired];
}
 
- (void)dismiss {
    [self.reminderManager modifyReminder:_reminder withBellState:YES];
    if (_detailViewShowMode == DeailViewShowModePresent) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSelector:@selector(checkRemindersExpired) withObject:self afterDelay:1.0];

    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (nil != _reminder) {
        if (nil == _reminder.longitude || [_reminder.longitude isEqualToString:@"0"]) {
            _sections = [[NSArray alloc] initWithObjects:@"内容", @"时间",nil];
        }else {
            _sections = [[NSArray alloc] initWithObjects:@"内容", @"时间",@"地图",nil];
        }
    }
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM-dd HH:mm"];
    if (nil == _friend || [[_friend.userID stringValue] isEqualToString:[UserManager defaultManager].userID]) {
        self.title = @"来自:我";
    }else {
        self.title = [NSString stringWithFormat:@"来自:%@", _friend.nickname];
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44.0;
    [self.tableView reloadData];
    
    [self initTableFooterView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[SoundManager defaultSoundManager] stopAudio];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier;
    UITableViewCell * cell;
    ReminderDetailAudioCell * audioCell;

    if (0 == indexPath.section) {
        CellIdentifier = @"ReminderDetailAudioCell";
                audioCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (audioCell == nil) {
            audioCell = [[ReminderDetailAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            audioCell.delegate = self;
        }
        audioCell.labelTitle.text = [_sections objectAtIndex:indexPath.section];
        
        audioCell.reminder = _reminder;
        audioCell.indexPath = indexPath;
        audioCell.audioState = AudioStateNormal;
        if (_detailViewShowMode == DeailViewShowModePresent) {
            [audioCell palyAudio:audioCell.btnAudio];
        }
        cell = audioCell;
    }else {
        CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = [_sections objectAtIndex:indexPath.section];
        if (1 == indexPath.section) {
            cell.detailTextLabel.text = [_dateFormatter stringFromDate:_reminder.triggerTime];
        }else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
        
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (2 == indexPath.section) {
        ReminderMapViewController * controller = [[ReminderMapViewController alloc] initWithNibName:@"ReminderMapViewController" bundle:nil];
        controller.reminder = _reminder;
        controller.type = MapOperateTypeShow;
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:nil];}

}

#pragma mark - ReminderManager Delegate
- (void)updateReminderReadStateSuccess:(Reminder *)reminder {
    [super updateReminderReadStateSuccess:reminder];
    [_btnFinish setHidden:NO];
}
    
@end
