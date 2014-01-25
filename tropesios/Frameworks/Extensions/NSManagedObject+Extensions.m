//
//  NSManagedObject+Extensions.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 22/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "NSManagedObject+Extensions.h"

@implementation NSManagedObject (Extensions)

+ (id)newIn:(NSManagedObjectContext*)managedObjectContext;
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:managedObjectContext];
}

+ (NSArray*)in:(NSManagedObjectContext*)managedObjectContext getPropertiesByName:(NSString*)firstProperty, ...;
{
    NSMutableArray *properties = [NSMutableArray new];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:managedObjectContext];
    NSDictionary *propertiesByName = entityDescription.propertiesByName;
    
    
    [properties addObject:[propertiesByName objectForKey:firstProperty]];
    
    
    va_list args;
    va_start(args, firstProperty);
    
    id arg = nil;
    while ((arg = va_arg(args, id)) != nil) {
        [properties addObject:[propertiesByName objectForKey:arg]];
    }
    
    va_end(args);
    
    return properties;
}

+ (id)in:(NSManagedObjectContext*)managedObjectContext getOneWithId:(NSManagedObjectID*)objectId;
{
    // TODO Handle error
    return [managedObjectContext existingObjectWithID:objectId error:nil];
}

+ (id)in:(NSManagedObjectContext*)managedObjectContext getOneWithPredicate:(NSString*)predicate, ...;
{
    va_list args;
    va_start(args, predicate);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(self)];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:predicate arguments:args];
    fetchRequest.fetchLimit = 1;
    
    va_end(args);
    
    // TODO Handle error
    NSArray* objects = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return objects.count > 0 ? objects[0] : nil;
}

@end
