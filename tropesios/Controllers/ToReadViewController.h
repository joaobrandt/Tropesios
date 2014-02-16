//
//  ToReadViewController.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 16/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PageManager.h"

@interface ToReadViewController : UITableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PageManager *pageManager;

- (IBAction)edit:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)clear:(id)sender;

@end
