//
//  TextRemindDetailViewController.m
//  date
//
//  Created by maoyu on 12-12-25.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "TextReminderDetailViewController.h"

@interface TextReminderDetailViewController () {
    CGSize _labelSize;
}

@end

@implementation TextReminderDetailViewController

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
    _labelSize = [self.reminder.desc sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(100, MAXFLOAT) lineBreakMode: NSLineBreakByTruncatingTail];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_labelSize.height > 44) {
            return _labelSize.height;
        }
    }
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier;
    UITableViewCell * cell;
    CellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (0 == indexPath.section) {
        cell.textLabel.text = @"内容";
        cell.detailTextLabel.text = self.reminder.desc;
        cell.detailTextLabel.numberOfLines = 0;
        if (_labelSize.height > 44) {
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
            [cell.detailTextLabel sizeToFit];
        }else {
            cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        }
        
    }else {
        cell.textLabel.text = [self.sections objectAtIndex:indexPath.section];
        if (1 == indexPath.section) {
            cell.detailTextLabel.text = [super.dateFormatter stringFromDate:self.reminder.triggerTime];
        }else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}


@end
