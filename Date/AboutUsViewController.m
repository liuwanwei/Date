//
//  AboutUsViewController.m
//  date
//
//  Created by maoyu on 13-1-19.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "AboutUsViewController.h"
#import "GlobalFunction.h"

@interface AboutUsViewController () {
    NSArray * _array;
    NSArray * _arrayNumber;
    NSIndexPath  * _curIndexPath;
}
@end

@implementation AboutUsViewController
@synthesize tableView = _tableView;

- (void)initData {
    _array = [[NSArray alloc] initWithObjects:@"刘万伟",@"毛_宇",nil];
    _arrayNumber = [[NSArray alloc] initWithObjects:@"iharbor",@"maoyu417",nil];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self initData];
    self.title = @"关于我们";
    [self initMenuButton];
//    self.navigationController.navigationItem.hidesBackButton = YES;
    [[GlobalFunction defaultGlobalFunction] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_array objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"sinaWeiboLogo"];
    
    return cell;
}

#pragma TableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _curIndexPath = indexPath;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * title = [NSString stringWithFormat:@"看一看 @%@ 的微博？", [_array objectAtIndex:indexPath.row]];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
    [alertView show];
}

#pragma AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString * url = @"http://www.weibo.com/";
        url = [url stringByAppendingString:[_arrayNumber objectAtIndex:_curIndexPath.row]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
@end
