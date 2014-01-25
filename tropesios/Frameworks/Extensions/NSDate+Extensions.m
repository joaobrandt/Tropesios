//
//  NSDate+Extensions.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 22/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

- (NSInteger)daysIntervalSinceReferenceDate
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate interval:NULL forDate:[[NSDate alloc]initWithTimeIntervalSinceReferenceDate:0]];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate interval:NULL forDate:self];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
