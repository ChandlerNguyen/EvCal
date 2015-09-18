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

const static NSTimeInterval kFiveMinuteTimeInterval = 5.0 * 60.0;

- (NSDate*)nearestFiveMinutes
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* dateComponents = [calendar components:(NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    
    NSInteger minutes = dateComponents.minute % 5;
    NSTimeInterval secondsSinceFiveMinuteInterval = minutes * 60 + dateComponents.second;
    
    NSTimeInterval delta = 0.0;
    if (secondsSinceFiveMinuteInterval >= kFiveMinuteTimeInterval / 2.0) {
        // round up
        delta = kFiveMinuteTimeInterval - secondsSinceFiveMinuteInterval; // difference between current minutes seconds and five minutes
    } else {
        // round down
        delta = -secondsSinceFiveMinuteInterval;
    }
    
    return [self dateByAddingTimeInterval:delta];
}

@end
