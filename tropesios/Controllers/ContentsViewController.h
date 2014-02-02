//
//  ContentsViewController.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 26/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

@interface ContentsViewController : UITableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PageManager *pageManager;

@end
