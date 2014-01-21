//
//  Page.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 20/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content, History;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSString * pageId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Content *content;
@property (nonatomic, retain) History *histories;

@end
