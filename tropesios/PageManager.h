//
//  PageManager.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 12/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "Page.h"

@protocol PageSearchDelegate <NSObject>

- (void)resultsFound:(NSArray*)results;

@end

@interface PageManager : NSObject

@property (readonly, nonatomic) BOOL canGoBack;
@property (readonly, nonatomic) BOOL canGoForward;
@property (strong, nonatomic) Page *currentPage;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *lastSearchTerm;
@property (strong, nonatomic) NSArray *lastSearchResults;

@property (strong, nonatomic) id<PageSearchDelegate> searchDelegate;

- (void)goToPageWithId:(NSString*)pageId;
- (void)goToPage:(Page*)page;
- (void)goToForwardPage;
- (void)goToBackPage;

- (void)loadHistory;
- (void)saveHistory;

- (void)search:(NSString*)query;

@end
