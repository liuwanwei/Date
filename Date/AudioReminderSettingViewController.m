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
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateTriggerTimeCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateDescCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier;
    UITableViewCell * cell;
    ReminderSettingAudioCell * audioCell;
    
    if (0 == indexPath.row) {
        CellIdentifier = @"ReminderSettingAudioCell";
        audioCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (audioCell == nil) {
            audioCell = [[ReminderSettingAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            audioCell.delegate = self;
        }
        audioCell.labelTitle.text = @"内容";
        audioCell.reminder = self.reminder;
        audioCell.indexPath = indexPath;
        audioCell.audioState = AudioStateNormal;
        cell = audioCell;
        
    }else {
        CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (indexPath.row == 1) {
            cell.textLabel.text = @"标签";
            cell.detailTextLabel.text =  self.desc;
        }else if (indexPath.row == 2) {
            cell.textLabel.text = @"提醒时间";
            cell.detailTextLabel.text = [self stringTriggerTime];
        }else if (indexPath.row == 3){
            cell.textLabel.text = @"发送给";
            cell.detailTextLabel.text = self.receiver;
            if (NO == self.isLogin) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    return cell;
}
@end
