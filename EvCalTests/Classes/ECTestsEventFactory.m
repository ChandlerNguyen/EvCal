//
//  ECTestsEventFactory.m
//  EvCal
//
//  Created by Tom on 5/23/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECTestsEventFactory.h"

#import "NSDate+ECTestAdditions.h"
#import "NSDate+CupertinoYankee.h"

@implementation ECTestsEventFactory

#pragma mark - Properties

+ (NSArray*)titles
{
    static NSArray* _titles = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _titles = @[@"Short",
                    @"Medium Length Title",
                    @"Really long event title with the location and date built in to the title even thought they have separate fields",
                    ];
    });
    
    return _titles;
}

+ (NSArray*)locations
{
    static NSArray* _locations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locations = @[@"Somewhere",
                       @"123 Somewhere Street Room 123",
                       @"123 Somewhere Street, Room 123, There City, 12345, United States of There",
                       ];
    });
    
    return _locations;
}


#pragma mark - Creating Random Events

+ (EKEvent*)randomEventInStore:(EKEventStore *)store calendar:(EKCalendar *)calendar
{
    return [self randomEventInDay:[NSDate date] store:store calendar:calendar allowMultipleDays:NO];
}

+ (EKEvent*)randomEventInDay:(NSDate *)date store:(EKEventStore *)store calendar:(EKCalendar *)calendar allowMultipleDays:(BOOL)multipleDays
{
    NSArray* todayHours = [date hoursOfDay];
    
    NSInteger startIndex = (NSInteger)arc4random_uniform((u_int32_t)todayHours.count - 1);
    NSInteger duration = (NSInteger)arc4random_uniform((u_int32_t)todayHours.count * 60 * 60);
    NSDate* startDate = todayHours[startIndex];
    NSDate* endDate = [startDate dateByAddingTimeInterval:duration];
    
    // multiple days not allowed and end date is after the given date
    if (!multipleDays && [endDate compare:[date endOfDay]] == NSOrderedDescending) {
        endDate = [date endOfDay];
    }
    
    EKEvent* event = [EKEvent eventWithEventStore:store];
    event.startDate = startDate;
    event.endDate = endDate;
    event.calendar = calendar;
    
    event.title = [self randomTitle];
    event.location = [self randomLocation];
    
    return event;
}

+ (NSString*)randomTitle
{
    
    return self.titles[(NSInteger)arc4random_uniform((u_int32_t)self.titles.count)];
}

+ (NSString*)randomLocation
{
    return self.locations[(NSInteger)arc4random_uniform((u_int32_t)self.titles.count)];
}

@end
