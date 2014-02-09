//
//  TropesiosAppDelegate.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "TropesiosAppDelegate.h"
#import "PageViewController.h"
#import "HistoryViewController.h"
#import "ContentsViewController.h"

@implementation TropesiosAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize pageManager = _pageManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // **************************************
    // Registering preferences
    // **************************************
    [[NSUserDefaults standardUserDefaults] registerDefaults:
    @{
        PREFERENCE_FONT_SIZE: @1.0f,
        PREFERENCE_FONT_SERIF: @NO,
        PREFERENCE_SHOW_SPOILERS: @NO
    }];
    
    [NSFetchedResultsController deleteCacheWithName:@"MainCache"];
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
 
    PageViewController *pageViewController = (PageViewController*) [splitViewController.viewControllers lastObject];
    UITabBarController *tabBarController = (UITabBarController*) [splitViewController.viewControllers firstObject];
    
    // **************************************
    // Configurating PAGE
    // **************************************
    pageViewController.pageManager = self.pageManager;
    splitViewController.delegate = pageViewController;

    // **************************************
    // Configurating CONTENTS
    // **************************************
    UINavigationController *navigationController = (UINavigationController*)tabBarController.viewControllers[0];
    ContentsViewController *contentsViewController = (ContentsViewController*) navigationController.topViewController;
    contentsViewController.managedObjectContext = self.managedObjectContext;
    contentsViewController.pageManager = self.pageManager;
    contentsViewController.pageViewController = pageViewController;
    
    // **************************************
    // Configurating HISTORY
    // **************************************
    navigationController = (UINavigationController*)tabBarController.viewControllers[1];
    HistoryViewController *historyViewController = (HistoryViewController*) navigationController.topViewController;
    historyViewController.managedObjectContext = self.managedObjectContext;
    historyViewController.pageManager = self.pageManager;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.pageManager saveHistory];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedObjectContext != nil && [self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Properties

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil && self.persistentStoreCoordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel == nil) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tropesios" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tropesios.sqlite"];
    
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

- (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (PageManager *)pageManager
{
    if (_pageManager == nil) {
        _pageManager = [PageManager new];
        _pageManager.managedObjectContext = self.managedObjectContext;
    }
    return _pageManager;
}

@end
