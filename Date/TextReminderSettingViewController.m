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
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
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
            return 1;
        }
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier;
    UITableViewCell * cell;
    CellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        view.backgroundColor = [UIColor whiteColor];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundView = view;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.desc;
        cell.textLabel.numberOfLines = 3;
//        cell.textLabel.textColor = RGBColor(50, 79, 133);
//        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
    }else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"提醒";
            cell.imageView.image = [UIImage imageNamed:@"Calendar"];
            cell.detailTextLabel.text = [self stringTriggerTime];
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"发送给";
            cell.imageView.image = [UIImage imageNamed:@"Calendar"];
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
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [self clickTrigeerTimeRow:indexPath];
    }else if (indexPath.section == 1 && indexPath.row == 1 && YES == self.isLogin) {
        [self clickSendRow];
    }
}

@end
