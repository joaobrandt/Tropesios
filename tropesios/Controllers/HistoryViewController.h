//
//  HistoryViewController.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 19/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PageViewController.h"

@interface HistoryViewController : UITableViewController

@property (strong, nonatomic) PageViewController *pageViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)edit:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)clear:(id)sender;

@end
