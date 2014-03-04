//
//  TropesiosAppDelegate.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "TropesiosAppDelegate.h"
#import "PageViewController.h"
#import "ContentsViewController.h"
#import "HistoryViewController.h"
#import "ToReadViewController.h"

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
    
    // **************************************
    // Configurating TO READ
    // **************************************
    navigationController = (UINavigationController*)tabBarController.viewControllers[1];
    ToReadViewController *toReadViewController = (ToReadViewController*) navigationController.topViewController;
    toReadViewController.managedObjectContext = self.managedObjectContext;
    toReadViewController.pageManager = self.pageManager;
    
    return YES;
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    
    NSURL *storeURL = [ [self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tropesios.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError *error = nil;
    NSPersistentStore *persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (persistentStore == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        // Remove existing store
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
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
