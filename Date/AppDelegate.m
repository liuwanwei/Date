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
#import "BilateralFriendManager.h"
#import "RemindersInboxViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize navController = _navController;
@synthesize menuViewController = _menuViewController;
@synthesize window = _window;
@synthesize homeViewController = _homeViewController;

#pragma 私有函数
- (void)showRemindersNotificationViewControllerWithReminders:(Reminder *)reminder{
    ReminderDetailViewController * viewController = [[ReminderDetailViewController alloc] initWithNibName:@"ReminderDetailViewController" bundle:nil];
    viewController.reminder = reminder;
    viewController.friend = [[BilateralFriendManager defaultManager] bilateralFriendWithUserID:viewController.reminder.userID];
    viewController.detailViewShowMode = DeailViewShowModePresent;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    [_navController presentViewController:nav animated:YES completion:nil];
}

- (void)checkRemindersExpired {
    NSArray * reminders = [[ReminderManager defaultManager] remindersExpired];
    if (nil != reminders) {
        [self showRemindersNotificationViewControllerWithReminders:[reminders objectAtIndex:0]];
    }
}

#pragma 类成员函数
- (void)makeMenuViewVisible {
    _navController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    _navController.view.layer.shadowOpacity = 0.4f;
    _navController.view.layer.shadowOffset = CGSizeMake(-12.0, 1.0f);
    _navController.view.layer.shadowRadius = 7.0f;
    _navController.view.layer.masksToBounds = NO;
    [_menuViewController setVisible:YES];
}

+(AppDelegate *)delegate{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate;
}

#pragma 事件函数
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SinaWeiboManager defaultManager] initSinaWeibo];
    
    //HomeViewController * viewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    _homeViewController = [[RemindersInboxViewController alloc] initWithNibName:@"RemindersInboxViewController" bundle:nil];
    _navController = [[UINavigationController alloc] initWithRootViewController:_homeViewController];
    
    _menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    _menuViewController.view.frame = CGRectMake(0, 20, 320, 460);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _navController;
    [self.window addSubview:_menuViewController.view];
    
    [_menuViewController setVisible:NO];
    [self.window makeKeyAndVisible];
    
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        //NSString * reminderId = [localNotif.userInfo objectForKey:@"key"];
    }
    
    [[ReminderManager defaultManager] updateAppBadge];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self checkRemindersExpired];
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
    [self checkRemindersExpired];
    //UIApplicationState state = application.applicationState;
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

@end
