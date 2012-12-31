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

@interface AudioReminderSettingViewController () {
     NSArray * _tags;
}

@end

@implementation AudioReminderSettingViewController

#pragma 私有函数
- (void)initData {
    [super initData];
    _tags = [[NSArray alloc] initWithObjects:@"记得做", @"记得带", @"记得买",@"记一下", nil];
    if (SettingModeNew == self.settingMode) {
        SoundManager * manager = [SoundManager defaultSoundManager];
        self.reminder.audioUrl = [manager.recordFileURL relativePath];
        self.reminder.audioLength = [NSNumber numberWithInteger:manager.currentRecordTime];
    }
}

- (void)updateReceiverCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateTriggerTimeCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (SettingModeModify == self.settingMode) {
        return 3;
    }else if (SettingModeShow == self.settingMode) {
        return 3;
    }
    
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        if (NO == self.isSpread){
            return 44.0f;
        }else {
            return 275.0f;
        }
    }
    
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
        }
        if (self.settingMode != SettingModeShow) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"标签";
            if (nil == self.reminder.desc) {
                self.reminder.desc = [_tags objectAtIndex:0];
            }
            cell.detailTextLabel.text =  self.reminder.desc;
        }else if (indexPath.row == 2) {
            cell.textLabel.text = @"提醒时间";
            cell.detailTextLabel.text = [self stringTriggerTime];
        }else if (indexPath.row == 3){
            cell.textLabel.text = @"发送给";
            cell.detailTextLabel.text = self.receiver;
            if (NO == self.isLogin) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            /*cell.textLabel.text = @"地点";
             if (_reminder.longitude.length == 0 || _reminder.latitude.length == 0) {
             cell.detailTextLabel.text = @"未设置";
             }else{
             cell.detailTextLabel.text = @"已设置";
             }*/
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.settingMode == SettingModeShow) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        CustomChoiceViewController * choiceViewController = [[CustomChoiceViewController alloc] initWithStyle:UITableViewStyleGrouped];
        choiceViewController.choices = _tags;
        if (self.reminder.desc != nil) {
            choiceViewController.currentChoices = [NSArray arrayWithObject:self.reminder.desc];
        }
        choiceViewController.delegate = self;
        choiceViewController.type = SingleChoice;
        choiceViewController.autoDisappear = YES;
        
        [self.navigationController pushViewController:choiceViewController animated:YES];
    }else if (indexPath.row == 2) {
        [self clickTrigeerTimeRow:indexPath];
    }else if (indexPath.row == 3 && YES == self.isLogin) {
        [self clickSendRow];
    }
}


@end
