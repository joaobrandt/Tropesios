//
//  HistoryViewController.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 19/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "HistoryViewController.h"
#import "History.h"
#import "Page.h"

@interface HistoryViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation HistoryViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController*)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        [NSFetchedResultsController deleteCacheWithName:@"MainCache"];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([History class])];
        fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]];
        fetchRequest.fetchBatchSize = 20;
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"dateName" cacheName:@"MainCache"];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        exit(-1);
    }
    
    [self done:nil];
}

#pragma mark - Actions

- (IBAction)edit:(id)sender
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clear:)];
    self.navigationItem.leftBarButtonItem = clearButton;
    
    self.tableView.editing = YES;
}

- (IBAction)done:(id)sender
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    self.navigationItem.leftBarButtonItem = nil;
    
    self.tableView.editing = NO;
}

- (IBAction)clear:(id)sender
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([History class])];
    fetchRequest.includesPropertyValues = NO;
    
    NSArray* histories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (History* history in histories) {
        [self.managedObjectContext deleteObject:history];
    }
    
    [self.managedObjectContext save:nil];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.fetchedResultsController.sections.count == 0) {
        return 0;
    }
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.fetchedResultsController.sections.count == 0) {
        return nil;
    }
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    History *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    cell.textLabel.text = history.page.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    History *history = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self.pageViewController goToPage:history.page];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        case NSFetchedResultsChangeUpdate:
            // TODO Update cell
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
