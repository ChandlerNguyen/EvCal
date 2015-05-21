//
//  NSDate+ECTestAdditions.m
//  EvCal
//
//  Created by Tom on 5/21/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "NSDate+ECTestAdditions.h"

@implementation NSDate (ECTestAdditions)

+ (NSDate*)randomDate
{
    NSInteger dayDelta = arc4random_uniform(365 * 2 + 1); // EvCal currently supports dates 2 years ahead or behind
    NSInteger direction = arc4random_uniform(2) ? -1 : 1; // determine if it's a future or past date
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    components.day += dayDelta * direction;
    
    return [calendar dateFromComponents:components];
}

@end
