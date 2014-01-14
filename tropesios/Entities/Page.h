//
//  Page.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 12/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubPage, Topic;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSString * pageId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * contents;
@property (nonatomic, retain) NSDate * fetchedIn;
@property (nonatomic, retain) NSSet *subPages;
@property (nonatomic, retain) NSSet *topics;
@end

@interface Page (CoreDataGeneratedAccessors)

- (void)addSubPagesObject:(SubPage *)value;
- (void)removeSubPagesObject:(SubPage *)value;
- (void)addSubPages:(NSSet *)values;
- (void)removeSubPages:(NSSet *)values;

- (void)addTopicsObject:(Topic *)value;
- (void)removeTopicsObject:(Topic *)value;
- (void)addTopics:(NSSet *)values;
- (void)removeTopics:(NSSet *)values;

@end
