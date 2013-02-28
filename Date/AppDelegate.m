//
//  AppDelegate.m
//  Date
//
//  Created by maoyu on 12-11-10.
//  Copyright (c) 2012年 Liu&Mao. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "UserManager.h"
#import "SinaWeiboManager.h"
#import "OnlineFriendsRemindViewController.h"
#import "ReminderManager.h"
#import "RemindersNotificationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ReminderDetailViewController.h"
#import "TextReminderDetailViewController.h"
#import "BilateralFriendManager.h"
#import "RemindersInboxViewController.h"
#import "ReminderSettingViewController.h"
#import "GlobalFunction.h"
#import "MobClick.h"

@interface AppDelegate () {
    BOOL _showingAlert;
    Reminder * _alertedReminder;
}
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize navController = _navController;
@synthesize menuViewController = _menuViewController;
@synthesize window = _window;
@synthesize homeViewController = _homeViewController;
@synthesize revealSideViewController = _revealSideViewController;

#pragma 私有函数
- (void)showRemindersNotificationViewControllerWithReminders:(Reminder *)reminder{
    ReminderDetailViewController * viewController;
    if (nil == reminder.audioUrl || [reminder.audioUrl isEqualToString:@""]) {
         viewController = [[TextReminderDetailViewController alloc] initWithNibName:@"TextReminderDetailViewController" bundle:nil];
    }else {
         viewController = [[ReminderDetailViewController alloc] initWithNibName:@"ReminderDetailViewController" bundle:nil];
    }
   
    viewController.reminder = reminder;
    viewController.friend = [[BilateralFriendManager defaultManager] bilateralFriendWithUserID:viewController.reminder.userID];
    viewController.detailViewShowMode = DeailViewShowModePresent;
    viewController.parentController = _homeViewController;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    [_navController presentViewController:nav animated:YES completion:nil];
}

- (void)showAlertViewWithReminder:(Reminder *)reminder {
    UIAlertView * alertView;
    BilateralFriend * friend = [[BilateralFriendManager defaultManager] bilateralFriendWithUserID:reminder.userID];
    NSString * nickname;
    NSString * userId = [reminder.userID stringValue];
    if ([userId isEqualToString:[UserManager defaultManager].oneselfId]) {
        nickname = @"";
    }else {
        if (nil == friend) {
            nickname = [NSString stringWithFormat:@"%@ ",[reminder.userID stringValue]];
        }else {
            nickname = [NSString stringWithFormat:@"%@ ",friend.nickname];
        }
    }
    NSString * title;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString * time = [formatter stringFromDate:reminder.triggerTime];
    title  = time;
    NSString * message = [nickname stringByAppendingString:@"提醒:"];
    message = [message stringByAppendingString:reminder.desc];
    
    if (nil != reminder.audioUrl && ![reminder.audioUrl isEqualToString:@""]) {
        [[SoundManager defaultSoundManager] playAudio:reminder.audioUrl];
    }
    
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"查看"otherButtonTitles:@"知道了", nil, nil];
    alertView.restorationIdentifier = reminder.id;
    [alertView show];
    
    _alertedReminder = reminder;
}

- (void)checkRemindersExpired {
    NSArray * reminders = [[ReminderManager defaultManager] remindersExpired];
    if (nil != reminders) {
        //[self showRemindersNotificationViewControllerWithReminders:[reminders objectAtIndex:0]];
        _showingAlert = YES;
        [self showAlertViewWithReminder:[reminders objectAtIndex:0]];
    }
}

- (void)handleAlarmPlayFinishedMessageMessage:(NSNotification *)note {
    [self checkRemindersExpired];
}

#pragma 类成员函数

+(AppDelegate *)delegate{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate;
}


#pragma 事件函数
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SinaWeiboManager defaultManager] initSinaWeibo];
    [[ReminderManager defaultManager] createDefaultReminders];
    
    _homeViewController = [[RemindersInboxViewController alloc] initWithNibName:@"RemindersInboxViewController" bundle:nil];
    _navController = [[UINavigationController alloc] initWithRootViewController:_homeViewController];
    
    _revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:_navController];
    
    [[GlobalFunction defaultInstance] customizeNavigationBar:_navController.navigationBar];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
//    _menuViewController.view.frame = CGRectMake(0, 20, 320, self.window.frame.size.height);
    
    self.window.rootViewController = _revealSideViewController;
//    [self.window addSubview:_menuViewController.view];
    
//    _menuViewController.view.hidden = YES;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAlarmPlayFinishedMessageMessage:) name:kAlarmPlayFinishedMessage
                                               object:nil];
    
    [MobClick startWithAppkey:kUMengAppKey];

    
    /*UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        //NSString * reminderId = [localNotif.userInfo objectForKey:@"key"];
    }*/
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIApplicationState state = application.applicationState;
    if (YES == _showingAlert) {
#ifdef DEBUG
        NSLog(@"不允许弹出提醒，因为上一个没有处理完。");
#endif
        return;
    }else {
        if (UIApplicationStateActive == state) {
            [[SoundManager defaultSoundManager] playAlarmVoice];
        }
    }
   
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[UserManager defaultManager] updateDeviceTokenRequest:token];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[SinaWeiboManager defaultManager].sinaWeibo applicationDidBecomeActive];
    [[ReminderManager defaultManager] getRemoteRemindersRequest];
    [MobClick event:kUMengEventLaunchTimes];
    if (NO == _showingAlert) {
        [self checkRemindersExpired];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Date" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Date.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[SinaWeiboManager defaultManager].sinaWeibo handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[SinaWeiboManager defaultManager].sinaWeibo handleOpenURL:url];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex %d", buttonIndex);
    [[SoundManager defaultSoundManager] stopAudio];
    ReminderManager * manager = [ReminderManager defaultManager];
    Reminder * reminder = [manager reminderWithId:alertView.restorationIdentifier];
    [manager modifyReminder:reminder withBellState:YES];
    [_homeViewController initDataWithAnimation:NO];
    
    if (buttonIndex == 0) {
        ReminderSettingViewController * controller = [ReminderSettingViewController createController:_alertedReminder withDateType:DataTypeToday];
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:controller];
        [[GlobalFunction defaultInstance] customizeNavigationBar:nav.navigationBar];
        [_navController presentViewController:nav animated:YES completion:nil];
        
        // TODO 弹出界面关闭时，调用下面两行，否则无法处理连续到期的提醒（延迟查看时）。
        _showingAlert = NO;
//        [self checkRemindersExpired];
    }else{
        _showingAlert = NO;
        [self checkRemindersExpired];
    }
}
@end
