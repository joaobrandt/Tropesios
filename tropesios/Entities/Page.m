//
//  Page.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 20/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "Page.h"
#import "Content.h"
#import "History.h"


@implementation Page

@dynamic pageId;
@dynamic title;
@dynamic content;
@dynamic histories;

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - %@", self.pageId, self.title];
}

@end
