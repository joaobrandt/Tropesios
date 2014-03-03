//
//  SearchViewController.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 10/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchEntry.h"

@interface SearchViewController () <PageSearchDelegate>

@property (strong, nonatomic) NSArray *searchResults;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"pageManager" options:0 context:nil];
    [self addObserver:self forKeyPath:@"searchTextField" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"pageManager"]) {
        [self removeObserver:self forKeyPath:@"pageManager"];
        
        self.pageManager.searchDelegate = self;
        self.searchResults = self.pageManager.lastSearchResults;
        
        if (self.searchResults == nil) {
            self.searchResults = @[];
        }
        
        [self.tableView reloadData];
    }
    
    if ([keyPath isEqualToString:@"searchTextField"]) {
        [self removeObserver:self forKeyPath:@"searchTextField"];
        
        [self.searchTextField addTarget:self action:@selector(searchTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    }
}


- (IBAction)searchTextFieldChanged:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(search) object:nil];
    [self performSelector:@selector(search) withObject:nil afterDelay:0.5];
}

- (void)search
{
    [self.pageManager search:self.searchTextField.text];
}

- (void)resultsFound:(NSArray *)results
{
    self.searchResults = results;
    [self.tableView reloadData];
}

- (void)resultsFound;
{
    self.searchResults = nil;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults != nil ? self.searchResults.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    if (self.searchResults != nil) {
        SearchEntry *entry = [self.searchResults objectAtIndex:indexPath.row];
    
        cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        cell.textLabel.text = entry.text;
        cell.detailTextLabel.text = entry.snippet;
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"emptyResultsCell" forIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchResults == nil) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else {
        SearchEntry *entry = [self.searchResults objectAtIndex:indexPath.row];
        [self.pageManager goToPageWithId:entry.pageId];
    
        [self.searchTextField resignFirstResponder];
        [self.popover dismissPopoverAnimated:YES];
    }
    
}

@end
