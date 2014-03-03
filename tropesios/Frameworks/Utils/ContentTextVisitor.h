//
//  ContentTextVisitor.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 03/03/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "TFHppleElement.h"
#import "TFHppleElement+Visitors.h"

@interface ContentTextVisitor : NSObject <Visitor>

+ (NSString*)contentTextOf:(TFHppleElement*) element;
+ (NSString*)contentTextOf:(TFHppleElement*) element filter:(BOOL (^)(TFHppleElement *element))filter;


@end
