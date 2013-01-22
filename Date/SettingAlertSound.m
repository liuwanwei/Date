//
//  SettingAlertSound.m
//  Date
//
//  Created by Liu Wanwei on 13-1-22.
//  Copyright (c) 2013年 Liu&Mao. All rights reserved.
//

#import "SettingAlertSound.h"
#import "GlobalFunction.h"
#import "SoundManager.h"

@interface SettingAlertSound (){
    NSArray * _soundTitles;
    NSArray * _soundTypes;
    int _selectedSound;
}

@end

@implementation SettingAlertSound

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[GlobalFunction defaultGlobalFunction] initNavleftBarItemWithController:self withAction:@selector(back)];

    _soundTitles = [[[SoundManager defaultSoundManager] aviableAlertSounds] objectAtIndex:0];
    _soundTypes = [[[SoundManager defaultSoundManager] aviableAlertSounds] objectAtIndex:1];
    
    _selectedSound = -1;
    
    self.title = @"提醒声音";
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
    return [_soundTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_soundTitles objectAtIndex:indexPath.row];
    
    NSString * currentSound = [[SoundManager defaultSoundManager] alertSound];
    if ([currentSound isEqualToString: [_soundTypes objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedSound = indexPath.row;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"修改声音后，将在创建新的提醒时生效。";
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 修改界面选中效果
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (_selectedSound != -1 && _selectedSound != indexPath.row) {
        NSIndexPath * lastIndexPath = [NSIndexPath indexPathForRow:_selectedSound inSection:indexPath.section];
        UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _selectedSound = indexPath.row;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // 保存选中的声音。
    NSString * soundName = [_soundTypes objectAtIndex:indexPath.row];
    SoundManager * soundManager = [SoundManager defaultSoundManager];
    soundManager.alertSound = soundName;
    
    // 播放当前选中的声音。
    [soundManager playAlertSound:soundName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UINotificationRefreshCell object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"section", [NSNumber numberWithInt:2], @"row", nil]];
}

@end
