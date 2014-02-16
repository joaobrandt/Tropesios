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
    
    self.searchResults = [NSArray new];
    [self addObserver:self forKeyPath:@"pageManager" options:0 context:nil];
    [self addObserver:self forKeyPath:@"searchTextField" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"pageManager"]) {
        self.pageManager.searchDelegate = self;
        
        [self removeObserver:self forKeyPath:@"pageManager"];
    }
    
    if ([keyPath isEqualToString:@"searchTextField"]) {
        [self.searchTextField addTarget:self action:@selector(searchTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        
        [self removeObserver:self forKeyPath:@"searchTextField"];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"searchCell";
    
    SearchEntry *entry = [self.searchResults objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = entry.text;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchEntry *entry = [self.searchResults objectAtIndex:indexPath.row];
    [self.pageManager goToPageWithId:entry.pageId];
    [self.popover dismissPopoverAnimated:YES];
}

@end
