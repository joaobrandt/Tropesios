//
//  TFHppleElement+Visitors.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 03/03/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "TFHppleElement.h"

@protocol Visitor <NSObject>

- (void)visit:(TFHppleElement*) element;

@end

@interface TFHppleElement (Visitors)

- (void)accept:(id<Visitor>)visitor;

@end
