//
//  ECTestsDateRange.m
//  EvCal
//
//  Created by Tom on 5/21/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECTestsEventQuery.h"
#import "NSDate+ECTestAdditions.h"
#import "NSDate+CupertinoYankee.h"

@implementation ECTestsEventQuery

- (instancetype)init
{
    self = [self initWithStartDate:nil type:ECTestsEventQueryTypeDay calendars:nil];
    return self;
}

- (instancetype)initWithStartDate:(NSDate *)startDate type:(ECTestsEventQueryType)type calendars:(NSArray *)calendars
{
    self = [super init];
    if (self) {
        if (!startDate) {
            startDate = [NSDate randomDate];
        }
        
        NSDate* adjustedStartDate = [ECTestsEventQuery adjustStartDate:startDate type:type];
        self.startDate = adjustedStartDate;
        self.endDate = [ECTestsEventQuery endDateForType:type startDate:startDate];
        self.calendars = calendars;
    }
    
    return self;
}

+ (NSDate*)adjustStartDate:(NSDate*)startDate type:(ECTestsEventQueryType)type
{
    NSDate* adjustedStartDate = nil;
    switch (type) {
        case ECTestsEventQueryTypeDay:
            adjustedStartDate = [startDate beginningOfDay];
            break;
            
        case ECTestsEventQueryTypeWeek:
            adjustedStartDate = [startDate beginningOfWeek];
            break;
            
        case ECTestsEventQueryTypeMonth:
            adjustedStartDate = [startDate beginningOfMonth];
            break;
            
        case ECTestsEventQueryTypeYear:
            adjustedStartDate = [startDate beginningOfYear];
            break;
    }
    
    return adjustedStartDate;
}

+ (NSDate*)endDateForType:(ECTestsEventQueryType)type startDate:(NSDate*)startDate
{
    NSDate* endDate = nil;
    switch (type) {
        case ECTestsEventQueryTypeDay:
            endDate = [startDate endOfDay];
            break;
            
        case ECTestsEventQueryTypeWeek:
            endDate = [startDate endOfWeek];
            break;
            
        case ECTestsEventQueryTypeMonth:
            endDate = [startDate endOfMonth];
            break;
            
        case ECTestsEventQueryTypeYear:
            endDate = [startDate endOfYear];
            break;
    }
    
    return endDate;
}

@end
