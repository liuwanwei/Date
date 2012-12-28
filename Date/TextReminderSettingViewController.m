//
//  TextReminderSettingViewController.m
//  date
//
//  Created by maoyu on 12-12-24.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "TextReminderSettingViewController.h"
#import "ReminderSettingDescCell.h"
#import "LMLibrary.h"

@interface TextReminderSettingViewController () {
    CGSize _labelSize;
}

@end

@implementation TextReminderSettingViewController

#pragma 私有函数
- (void)initData {
    [super initData];
    if (SettingModeNew == self.settingMode) {
        self.reminder.desc = self.desc;
    }
}

- (void)updateReceiverCell {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateTriggerTimeCell {
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
     _labelSize = [self.reminder.desc sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(100, MAXFLOAT) lineBreakMode: NSLineBreakByTruncatingTail];
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
    if (indexPath.row == 1) {
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
    CellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (0 == indexPath.row) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = RGBColor(56, 57, 61);
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.textLabel.text = self.reminder.desc;
        if (_labelSize.height > 44) {
            [cell.textLabel sizeToFit];
        }
    }else {
       cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self clickTrigeerTimeRow:indexPath];
    }else if (indexPath.row == 2 && YES == self.isLogin) {
        [self clickSendRow];
    }
}


@end
