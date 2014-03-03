//
//  ContentTextVisitor.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 03/03/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "ContentTextVisitor.h"

@interface ContentTextVisitor ()

@property (nonatomic, strong) NSMutableString* string;
@property (nonatomic, strong) BOOL (^filter)(TFHppleElement *element);

@end

@implementation ContentTextVisitor

+ (NSString*)contentTextOf:(TFHppleElement*) element
{
    return [ContentTextVisitor contentTextOf:element filter:nil];
}

+ (NSString*)contentTextOf:(TFHppleElement*) element filter:(BOOL (^)(TFHppleElement *element))filter
{
    ContentTextVisitor *visitor = [ContentTextVisitor new];
    visitor.string = [NSMutableString new];
    visitor.filter = filter;
    
    [element accept:visitor];
    
    return [visitor.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)visit:(TFHppleElement *)element
{
    if (self.filter == nil || self.filter(element)) {
    
        if (element.isTextNode) {
            [self.string appendString:element.content];
        } else {
            for (TFHppleElement *child in element.children) {
                [child accept:self];
            }
        }
        
    }
}

@end
