//
//  PageManager.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 12/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "Page.h"

@protocol PageManagerDelegate <NSObject>

- (void)pageLoaded:(Page*)page;

@end

@interface PageManager : NSObject

@property (strong, nonatomic) id<PageManagerDelegate> delegate;

- (void)loadPage:(Page*)page;
- (void)loadPageWithId:(NSString*)pageId;

@end
