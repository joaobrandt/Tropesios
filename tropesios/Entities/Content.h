//
//  Content.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 02/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;

@interface Content : NSManagedObject

@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) Page *page;

@end
