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
    
}

@end

@implementation TextReminderSettingViewController

#pragma 类成员函数
- (void)updateTriggerTimeCell {
    if (ReminderTypeReceiveAndNoAlarm == self.reminderType) {
        long long userId = [[[UserManager defaultManager] oneselfId] longLongValue];
        self.receiverId = [NSNumber numberWithLongLong:userId];
        self.receiver = @"自己";
    }
    [self.tableView reloadData];
}

- (void)updateReceiverCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    //[self computeFontSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 1;
    }else {
        if (ReminderTypeReceiveAndNoAlarm == self.reminderType || NO == self.isLogin) {
            return 2;
        }
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        CellIdentifier = @"TextCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"TextCell" owner:self options:nil];
            cell = self.textCell;
            self.textCell = nil;
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
            view.backgroundColor = [UIColor whiteColor];
            cell.backgroundView = view;
        }
        UILabel * label = (UILabel *)[cell viewWithTag:2];
        label.text = self.desc;
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
            view.backgroundColor = [UIColor whiteColor];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        [self clickTrigeerTimeRow:indexPath];
    }else if (indexPath.section == 1 && indexPath.row == 2 && YES == self.isLogin) {
        [self clickSendRow];
    }
}

@end
