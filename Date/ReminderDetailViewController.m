//
//  ReminderDetailViewController.m
//  date
//
//  Created by maoyu on 12-12-6.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderDetailViewController.h"

@interface ReminderDetailViewController () {
    NSArray * _sections;
    NSDateFormatter * _dateFormatter;
}

@end

@implementation ReminderDetailViewController
@synthesize reminder = _reminder;
@synthesize friend = _friend;
@synthesize tableView = _tableView;

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
    _sections = [[NSArray alloc] initWithObjects:@"提醒时间", nil];
     _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM-dd HH:mm"];
    self.title = _friend.nickname;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_sections objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_dateFormatter stringFromDate:_reminder.triggerTime];
    
    return cell;
}

@end
