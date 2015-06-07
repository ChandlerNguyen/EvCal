//
//  NSDate+ECEventAdditions.m
//  EvCal
//
//  Created by Tom on 6/7/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "NSDate+ECEventAdditions.h"

@implementation NSDate (ECEventAdditions)

- (NSDate*)dateWithTimeOfDate:(NSDate *)time
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* timeComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:time];
    NSDateComponents* dateComponents = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    
    dateComponents.hour = timeComponents.hour;
    dateComponents.minute = timeComponents.minute;
    dateComponents.second = timeComponents.second;
    
    return [calendar dateFromComponents:dateComponents];
}

@end
