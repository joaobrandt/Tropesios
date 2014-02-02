//
//  NSManagedObject+Extensions.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 22/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Extensions)


+ (id)newIn:(NSManagedObjectContext*)managedObjectContext;
+ (NSArray*)in:(NSManagedObjectContext*)managedObjectContext getPropertiesByName:(NSString*)property, ... NS_REQUIRES_NIL_TERMINATION;

+ (id)in:(NSManagedObjectContext*)managedObjectContext getOneWithId:(NSManagedObjectID*)objectId;
+ (id)in:(NSManagedObjectContext*)managedObjectContext getOneWithPredicate:(NSString*)predicate, ...;
+ (void)in:(NSManagedObjectContext *)managedObjectContext deleteAllWithPredicate:(NSString*)predicate, ...;

@end
