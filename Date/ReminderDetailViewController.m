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
    NSArray * _sections;
    NSDateFormatter * _dateFormatter;
}

@end

@implementation ReminderDetailViewController
@synthesize reminder = _reminder;
@synthesize friend = _friend;
@synthesize tableView = _tableView;
@synthesize detailViewShowMode = _detailViewShowMode;

- (void)checkRemindersExpired {
     [[AppDelegate delegate] checkRemindersExpired];
}
 
- (void)dismiss {
    [self.reminderManager modifyReminder:_reminder withBellState:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(checkRemindersExpired) withObject:self afterDelay:1.0];
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
            _sections = [[NSArray alloc] initWithObjects:@"内容", @"闹铃时间",nil];
        }else {
            _sections = [[NSArray alloc] initWithObjects:@"内容", @"闹铃时间",@"地图",nil];
        }
    }
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM-dd HH:mm"];
    if ([[_friend.userID stringValue] isEqualToString:[UserManager defaultManager].userID]) {
        self.title = @"来自:我";
    }else {
        self.title = [NSString stringWithFormat:@"来自:%@", _friend.nickname];
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44.0;
    [self.tableView reloadData];
    
    if (_detailViewShowMode  == DeailViewShowModePresent) {
        UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
@end
