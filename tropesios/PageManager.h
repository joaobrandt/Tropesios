//
//  PageManager.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 12/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "Page.h"

@interface PageManager : NSObject

@property (readonly, nonatomic) BOOL canGoBack;
@property (readonly, nonatomic) BOOL canGoForward;
@property (strong, nonatomic) Page *currentPage;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)goToPageWithId:(NSString*)pageId;
- (void)goToPage:(Page*)page;
- (void)goToForwardPage;
- (void)goToBackPage;

@end
