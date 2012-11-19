//
//  OnlineFriendsRemindViewController.m
//  Date
//
//  Created by maoyu on 12-11-15.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "OnlineFriendsRemindViewController.h"
#import "BilateralFriendManager.h"
#import "BilateralFriend.h"
#import "EGOImageView.h"

@interface OnlineFriendsRemindViewController () {
    NSArray * _newOnlinefriends;
}

@end

@implementation OnlineFriendsRemindViewController
@synthesize tableView = _tableView;
@synthesize friendCell = _friendCell;

- (void)initFriends {
    _newOnlinefriends = [[BilateralFriendManager defaultManager] newOnlineFriends];
    [self.tableView reloadData];
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
    self.tableView.rowHeight = 60.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initFriends];
    //TODO 不写这句话，程序走到tablecell时，会取不到EGOImageView Class。
    NSLog(@"%@", [EGOImageView class]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil != _newOnlinefriends) {
        return _newOnlinefriends.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    EGOImageView * imageView;
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"OnlineFriendRemindCell" owner:self options:nil];
        cell = _friendCell;
        self.friendCell = nil;
        
        imageView = (EGOImageView *)[cell viewWithTag:UIFriendImageTag];
        [imageView  setPlaceholderImage:[UIImage imageNamed:@"male"]];
    } else {
        imageView = (EGOImageView *)[cell viewWithTag:UIFriendImageTag];
    }
    
    BilateralFriend * friend = [_newOnlinefriends objectAtIndex:indexPath.row];
    if (nil != friend.imageUrl) {
        [imageView setImageURL:[NSURL URLWithString:friend.imageUrl]];
    }
    
    UILabel * nicknameLabel = (UILabel *)[cell viewWithTag:UIFriendNameTag];
    nicknameLabel.text = friend.nickname;
    
    return cell;
}

@end
