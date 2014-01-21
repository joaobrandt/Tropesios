//
//  History.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 20/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;

@interface History : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * dateName;
@property (nonatomic, retain) Page *page;

@end
