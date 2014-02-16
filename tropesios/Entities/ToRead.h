//
//  ToRead.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 16/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ToRead : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * pageId;

@end
