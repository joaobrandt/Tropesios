//
//  History.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 25/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "History.h"
#import "Page.h"


@implementation History

@dynamic date;
@dynamic dateName;
@dynamic page;

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


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ >> %@", self.page, self.date];
}

@end
