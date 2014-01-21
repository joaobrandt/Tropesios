//
//  Content.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 20/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page, SubPage, Topic;

@interface Content : NSManagedObject

@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) NSSet *subPages;
@property (nonatomic, retain) NSSet *topics;
@property (nonatomic, retain) Page *page;
@end

@interface Content (CoreDataGeneratedAccessors)

- (void)addSubPagesObject:(SubPage *)value;
- (void)removeSubPagesObject:(SubPage *)value;
- (void)addSubPages:(NSSet *)values;
- (void)removeSubPages:(NSSet *)values;

- (void)addTopicsObject:(Topic *)value;
- (void)removeTopicsObject:(Topic *)value;
- (void)addTopics:(NSSet *)values;
- (void)removeTopics:(NSSet *)values;

@end
