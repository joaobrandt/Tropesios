//
//  SubPage.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 02/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;

@interface SubPage : NSManagedObject

@property (nonatomic, retain) NSString * subPageId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Page *page;

@end
