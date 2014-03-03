//
//  TFHppleElement+Visitors.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 03/03/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "TFHppleElement+Visitors.h"

@implementation TFHppleElement (Visitors)

- (void)accept:(id<Visitor>)visitor
{
    [visitor visit:self];
}

@end
