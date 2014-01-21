//
//  History.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 20/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "History.h"
#import "Page.h"


@implementation History

@dynamic date;
@dynamic dateName;
@dynamic page;

/*
- (void)setDate:(NSDate *)date
{
    [self willChangeValueForKey:@"date"];
    [self setPrimitiveValue:date forKey:@"date"];
    [self didChangeValueForKey:@"date"];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateName = [dateFormatter stringFromDate:self.date];
}
*/
- (NSString*)dateName
{
    if (self.date == nil) {
        return @"";
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    return [dateFormatter stringFromDate:self.date];
}

@end
