//
//  ReminderSettingTimeCell.m
//  date
//
//  Created by maoyu on 12-12-14.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "ReminderSettingTimeCell.h"

@interface ReminderSettingTimeCell () {
    NSArray * _days;
    NSMutableArray * _hours;
    NSMutableArray * _minutes;
}

@end

@implementation ReminderSettingTimeCell
@synthesize labelTitle = _labelTitle;
@synthesize switchTime = _switchTime;
@synthesize delegate = _delegate;
@synthesize triggerTime = _triggerTime;
@synthesize labelTriggerTime = _labelTriggerTime;
@synthesize pickerView = _pickerView;

#pragma 私有函数
- (void)initData {
    _days = [[NSArray alloc] initWithObjects:@"今天",@"明天",@"后天", nil];
    
    _minutes = [[NSMutableArray alloc] init];
    int step = 5;
    for(int i = 0; i < 60 ; i ++){
        if (i % step == 0) {
            [_minutes addObject:[NSString stringWithFormat:@"%02d", i]];
        }
    }
    
    _hours = [[NSMutableArray alloc] init];
    for (int i = 0; i < 24; i ++) {
        [_hours addObject:[NSString stringWithFormat:@"%02d", i]];
    }
}

- (void)initPickerView {
    NSDate * now = [NSDate date];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    [_pickerView selectRow:1 inComponent:0 animated:NO];
    NSDateFormatter * hour = [[NSDateFormatter alloc] init];
    [hour setDateFormat:@"HH"];
    NSString * currentDateStr = [hour stringFromDate:now];
    NSInteger hourIndex = [currentDateStr integerValue];
    [_pickerView selectRow:hourIndex inComponent:1 animated:NO];
    [hour setDateFormat:@"mm"];
    currentDateStr = [hour stringFromDate:now];
    [_pickerView selectRow:6 inComponent:2 animated:NO];
}

- (void)tiggerTime {
    NSDate * now = [NSDate date];
    NSDateFormatter * hour = [[NSDateFormatter alloc] init];
    [hour setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString * strTriggerDate = [hour stringFromDate:now];
    NSDate * triggerDate = [hour dateFromString:strTriggerDate];
    triggerDate = [triggerDate dateByAddingTimeInterval:24*60*60*[_pickerView selectedRowInComponent:0]];
    triggerDate = [triggerDate dateByAddingTimeInterval:[_pickerView selectedRowInComponent:1]*60*60];
    triggerDate = [triggerDate dateByAddingTimeInterval:[_pickerView selectedRowInComponent:2]*5*60];
    _triggerTime = triggerDate;
}

#pragma 事件函数
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ReminderSettingTimeCell" owner:self options:nil] ;
        self = [nib objectAtIndex:0];
        [self initData];
        [self initPickerView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)valueChanged:(UISwitch *)sender {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(valueChangedWithSwitch:)]) {
            [self.delegate performSelector:@selector(valueChangedWithSwitch:) withObject:sender];
        }
    }
}

- (void)setTriggerTime:(NSDate *)triggerTime {
    if (nil == triggerTime) {
        [_switchTime setOn:NO];
        _labelTriggerTime.text = @"";
    }else {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        _labelTriggerTime.text = [dateFormatter stringFromDate:triggerTime];
        [_switchTime setOn:NO];
    }
}

- (IBAction)clearTime:(UIButton *)sender {
    _triggerTime = nil;
    [self setTriggerTime:_triggerTime];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(triggerTimeChanged:)]) {
            [self.delegate performSelector:@selector(triggerTimeChanged:) withObject:_triggerTime];
        }
    }
}

#pragma  mark - PickerView data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _days.count;
    }else if(component == 1){
        return _hours.count;
    }else {
        return _minutes.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component == 0){
        return [_days objectAtIndex:row];
    }else if(component == 1) {
        return [_hours objectAtIndex:row];
    }else {
        return [_minutes objectAtIndex:row];
    }
}

#pragma  mark - PickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self tiggerTime];
    [self setTriggerTime:_triggerTime];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(triggerTimeChanged:)]) {
            [self.delegate performSelector:@selector(triggerTimeChanged:) withObject:_triggerTime];
        }
    }
}
@end
