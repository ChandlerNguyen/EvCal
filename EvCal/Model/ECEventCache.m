//
//  ECEventCache.m
//  EvCal
//
//  Created by Tom on 6/30/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECEventCache.h"
#import "NSDate+CupertinoYankee.h"

@interface ECEventCache()

@property (nonatomic, strong) NSDate* cacheStartDate;
@property (nonatomic, strong) NSDate* cacheEndDate;
@property (nonatomic, strong) NSMutableArray* events;

@end

@implementation ECEventCache

- (NSMutableArray*)events
{
    if (!_events) {
        _events = [[NSMutableArray alloc] init];
    }
    
    return _events;
}


- (NSArray*)eventsFrom:(NSDate *)startDate to:(NSDate *)endDate in:(NSArray *)calendars
{
    if (!self.cacheDataSource) {
        return nil;
    }
    
    if (![self verifyStartDate:startDate endDate:endDate]) {
        return nil;
    }
    
    
    [self expandCacheToIncludeStartDate:startDate endDate:endDate];
    
    
    return [self cachedEventsFrom:startDate to:endDate in:calendars];
}

- (BOOL)verifyStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    return (startDate && endDate && [startDate compare:endDate] == NSOrderedAscending);
}

- (BOOL)cacheContainsStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    return ([startDate compare:self.cacheStartDate] != NSOrderedAscending);
}

- (void)expandCacheToIncludeStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    NSDate* expandStartDate = [startDate beginningOfMonth];
    NSDate* expandEndDate = [endDate endOfMonth];
    
    if (!self.cacheEndDate) {
        self.events = nil;
        self.cacheStartDate = expandEndDate;
        self.cacheEndDate = expandEndDate;
    }
    
    BOOL prependEventsToCache = ([expandStartDate compare:self.cacheStartDate] == NSOrderedAscending);
    if (prependEventsToCache) {
        NSDate* prependEndDate = (self.cacheStartDate) ? self.cacheStartDate : expandEndDate;
        [self addEventsFromStartDate:expandStartDate endDate:prependEndDate locationInCache:0];
        self.cacheStartDate = expandStartDate;
    }
    
    BOOL appendEventsToCache = !self.cacheEndDate || ([self.cacheEndDate compare:expandEndDate] == NSOrderedDescending);
    if (appendEventsToCache) {
        NSDate* appendStartDate = (self.cacheEndDate) ? self.cacheEndDate : expandStartDate;
        [self addEventsFromStartDate:appendStartDate endDate:expandEndDate locationInCache:self.events.count];
        self.cacheEndDate = expandEndDate;
    }
}

- (void)addEventsFromStartDate:(NSDate*)startDate endDate:(NSDate*)endDate locationInCache:(NSInteger)loc
{
    NSArray* storedEvents = [self.cacheDataSource storedEventsFrom:startDate to:endDate];
   
    if (storedEvents) {
        NSIndexSet* eventsIndices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, storedEvents.count)];
        [self.events insertObjects:storedEvents atIndexes:eventsIndices];
    }
}

- (NSComparisonResult)compareEvent:(EKEvent*)event1 startAndEndDateWithEvent:(EKEvent*)event2
{
    NSComparisonResult startDateComparisonResult = [event1.startDate compare:event2.startDate];
    if (startDateComparisonResult != NSOrderedSame) {
        return [event1.endDate compare:event2.endDate];
    } else {
        return startDateComparisonResult;
    }
}

static NSInteger kEventsInRangeNotFound = -1;

- (NSArray*)cachedEventsFrom:(NSDate*)startDate to:(NSDate*)endDate in:(NSArray*)calendars
{
    NSRange eventsRange = [self rangeOfEventsFrom:startDate to:endDate];
    
    if (eventsRange.location != kEventsInRangeNotFound) {
        NSArray* eventsInRange = [self.events objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:eventsRange]];
    
        if (calendars) {
            NSMutableArray* eventsInCalendars = [[NSMutableArray alloc] init];
            for (EKEvent* event in eventsInRange) {
                if ([calendars containsObject:event.calendar]) {
                    [eventsInCalendars addObject:event];
                }
            }
            return (eventsInCalendars.count > 0) ? [eventsInCalendars copy] : nil; // match event store return scheme
        } else {
            return eventsInRange;
        }
    } else {
        return nil;
    }
}

- (NSRange)rangeOfEventsFrom:(NSDate*)startDate to:(NSDate*)endDate
{
    NSInteger startIndex = kEventsInRangeNotFound;
    NSInteger endIndex = kEventsInRangeNotFound;
    
    for (int i = 0; i < self.events.count; i++) {
        EKEvent* current = self.events[i];
        if ([self event:current isInDateRangeFrom:startDate to:endDate]) {
            startIndex = i;
            break;
        }
    }
    
    if (startIndex >= 0) {
        endIndex = startIndex;
        for (NSInteger i = startIndex; i < self.events.count; i++) {
            EKEvent* current = self.events[i];
            if ([self event:current isInDateRangeFrom:startDate to:endDate]) {
                endIndex = i;
            } else {
                break;
            }
        }
        return NSMakeRange(startIndex, (endIndex - startIndex) + 1);
    } else {
        DDLogError(@"Unable to find events in cache for date range from %@ to %@",
                   [[ECLogFormatter logMessageDateFormatter] stringFromDate:startDate],
                   [[ECLogFormatter logMessageDateFormatter] stringFromDate:endDate]);
        return NSMakeRange(startIndex, 0); // Return illegal range
    }
}

- (BOOL)event:(EKEvent*)event isInDateRangeFrom:(NSDate*)startDate to:(NSDate*)endDate
{
    BOOL startDateInRange = [event.startDate compare:startDate] != NSOrderedAscending &&
                            [event.startDate compare:endDate] == NSOrderedAscending;
    BOOL endDateInRange = [event.endDate compare:startDate] == NSOrderedDescending &&
                          [event.endDate compare:endDate] != NSOrderedDescending;
    
    return startDateInRange && endDateInRange;
}

- (void)flush
{
    self.events = nil;
}

#pragma mark - Data source

- (NSArray*)requestEventsFrom:(NSDate*)startDate to:(NSDate*)endDate
{
    NSArray* events = [self.cacheDataSource storedEventsFrom:startDate to:endDate];
    return events;
}

@end
