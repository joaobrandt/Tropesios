//
//  Page.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 02/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content, History, SubPage, Topic;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSString * pageId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Content *content;
@property (nonatomic, retain) NSSet *histories;
@property (nonatomic, retain) Topic *topics;
@property (nonatomic, retain) SubPage *subPages;
@end

@interface Page (CoreDataGeneratedAccessors)

- (void)addHistoriesObject:(History *)value;
- (void)removeHistoriesObject:(History *)value;
- (void)addHistories:(NSSet *)values;
- (void)removeHistories:(NSSet *)values;

@end
