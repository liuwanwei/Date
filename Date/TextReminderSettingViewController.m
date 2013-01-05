//
//  TextReminderSettingViewController.m
//  date
//
//  Created by maoyu on 12-12-24.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "TextReminderSettingViewController.h"
#import "ReminderSettingDescCell.h"
#import "TextEditorViewController.h"
#import "LMLibrary.h"

@interface TextReminderSettingViewController () {
    CGSize _labelSize;
}

@end

@implementation TextReminderSettingViewController

#pragma 私有函数
- (void)initData {
    [super initData];
}

- (void)updateReceiverCell {
    [super updateReceiverCell];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateTriggerTimeCell {
    [super updateTriggerTimeCell];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)computeFontSize {
    _labelSize = [self.desc sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(100, MAXFLOAT) lineBreakMode: NSLineBreakByTruncatingTail];
}

- (void)updateDescCell {
    [self computeFontSize];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma 事件函数
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
    [self computeFontSize];
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
        //if (nil == self.reminder.triggerTime) {
            return 3;
        //}
        //return 2;
    }else if (self.settingMode == SettingModeShow) {
        return 2;
    }
    
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (_labelSize.height > 44) {
            return _labelSize.height;
        }
    }
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier;
    UITableViewCell * cell;
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
    
    if (0 == indexPath.row) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = RGBColor(56, 57, 61);
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.textLabel.text = self.desc;
        if (_labelSize.height > 44) {
            [cell.textLabel sizeToFit];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        if (indexPath.row == 1) {
            cell.textLabel.text = @"提醒时间";
            cell.detailTextLabel.text = [self stringTriggerTime];
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"发送给";
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
    if (self.settingMode == SettingModeShow) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        TextEditorViewController * editor = [[TextEditorViewController alloc] initWithStyle:UITableViewStyleGrouped];
        editor.text = self.desc;
        editor.parentController = self;
        [self.navigationController pushViewController:editor animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        [self clickTrigeerTimeRow:indexPath];
    }else if (indexPath.row == 2 && YES == self.isLogin) {
        [self clickSendRow];
    }
}


@end
