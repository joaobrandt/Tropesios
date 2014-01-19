//
//  HistoryViewController.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 19/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

@interface HistoryViewController : UITableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
