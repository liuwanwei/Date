//
//  AudioReminderSettingViewController.m
//  date
//
//  Created by maoyu on 12-12-24.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "AudioReminderSettingViewController.h"
#import "ReminderSettingAudioCell.h"
#import "CustomChoiceViewController.h"
#import "TextEditorViewController.h"
#import "LMLibrary.h"

@interface AudioReminderSettingViewController () {
    NSArray * _tags;
}

@end

@implementation AudioReminderSettingViewController

#pragma 私有函数
- (void)initData {
    _tags = [[NSArray alloc] initWithObjects:@"记得做", @"记得带", @"记得买",@"记一下", nil];
}

- (void)updateReceiverCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateTriggerTimeCell {
    if (ReminderTypeReceiveAndNoAlarm == self.reminderType) {
        long long userId = [[[UserManager defaultManager] oneselfId] longLongValue];
        self.receiverId = [NSNumber numberWithLongLong:userId];
        self.receiver = @"自己";
    }
    [self.tableView reloadData];
}

- (void)updateDescCell {
    [self computeFontSize];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else {
        if (ReminderTypeReceiveAndNoAlarm == self.reminderType || NO == self.isLogin) {
            return 2;
        }
        
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier;
    UITableViewCell * cell;
    ReminderSettingAudioCell * audioCell;
    
    if (0 == indexPath.section) {
        CellIdentifier = @"ReminderSettingAudioCell";
        audioCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (audioCell == nil) {
            audioCell = [[ReminderSettingAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            audioCell.delegate = self;
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
            view.backgroundColor = [UIColor whiteColor];
            audioCell.backgroundView = view;
        }
        audioCell.reminder = self.reminder;
        audioCell.labelDescription.text = self.desc;
        audioCell.indexPath = indexPath;
        audioCell.audioState = AudioStateNormal;
        cell = audioCell;
    }else {
       
        CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
            view.backgroundColor = [UIColor whiteColor];
            cell.backgroundView = view;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundView.backgroundColor = [UIColor clearColor];
        }else if (indexPath.row == 1) {
            cell.textLabel.text = @"提醒";
            cell.imageView.image = [UIImage imageNamed:@"reminderDetailsAlertType"];
            cell.detailTextLabel.text = [self stringTriggerTime];
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"发送给";
            cell.imageView.image = [UIImage imageNamed:@"reminderSettingContact"];
            cell.detailTextLabel.text = self.receiver;
            if (NO == self.isLogin) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        TextEditorViewController * editor = [[TextEditorViewController alloc] initWithNibName:@"TextEditorViewController" bundle:nil];
        editor.text = self.desc;
        editor.parentController = self;
        
        [self.navigationController pushViewController:editor animated:YES];
    }else if (indexPath.section == 1 && indexPath.row == 1) {
        [self clickTrigeerTimeRow:indexPath];
    }else if (indexPath.section == 1 && indexPath.row == 2 && YES == self.isLogin) {
        [self clickSendRow];
    }
}
@end
