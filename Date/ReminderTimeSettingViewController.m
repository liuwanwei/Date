//
//  ReminderTimeSettingViewController.m
//  date
//
//  Created by maoyu on 12-12-26.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderTimeSettingViewController.h"
#import "LMLibrary.h"
#import "AppDelegate.h"

@interface ReminderTimeSettingViewController () {
}

@end

@implementation ReminderTimeSettingViewController
@synthesize parentContoller = _parentContoller;
@synthesize datePick = _datePick;
@synthesize labelDay = _labelDay;
@synthesize labelDate = _labelDate;
@synthesize labelTime = _labelTime;
@synthesize btnClear = _btnClear;
@synthesize btnSet = _btnSet;

#pragma 私有函数
- (void)initPickerView {
    [_datePick setFrame:CGRectMake(0, 200, 320, 216)];
    [self.view addSubview:_datePick];
    _datePick.minimumDate = [NSDate date];
    [_datePick addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)valueChanged:(UIDatePicker *)datePicker {
    [self setLabelViewWithDate:datePicker.date];
}

- (void)initLabelView {
    NSDate * date;
    if (nil != _parentContoller.triggerTime) {
        date = _parentContoller.triggerTime;
    }else {
        date = [NSDate date];
    }
    [self setLabelViewWithDate:date];
}

- (void)setLabelViewWithDate:(NSDate *)date {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    NSString * day = [formatter stringFromDate:date];
    _labelDay.text = [_parentContoller custumDateString:day withShowDate:YES];
    //_labelDate.text = day;
    [formatter setDateFormat:@"HH:mm"];
    _labelTime.text = [formatter stringFromDate:date];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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
    [self initPickerView];
    [self initLabelView];
    [[AppDelegate delegate] initNavleftBarItemWithController:self withAction:@selector(back)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_datePick removeTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [_parentContoller updateTriggerTimeCell];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)clickClear:(id)sender {
    _parentContoller.triggerTime = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSet:(id)sender {
    _parentContoller.triggerTime = _datePick.date;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
