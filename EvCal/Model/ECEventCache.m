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
#import "EKEvent+ECAdditions.h"

@interface ECEventCache()

@property (nonatomic, strong) NSDate* cacheStartDate;
@property (nonatomic, strong) NSDate* cacheEndDate;
@property (nonatomic, strong) NSMutableArray* events;

@end

@implementation ECEventCache

#pragma mark - Constants

static NSInteger kEventsInRangeNotFound = -1;


#pragma mark - Lifecycle and Properties

- (NSMutableArray*)events
{
    if (!_events) {
        _events = [[NSMutableArray alloc] init];
    }
    
    return _events;
}


#pragma mark - Retreiving events

- (NSArray*)eventsFrom:(NSDate *)startDate to:(NSDate *)endDate in:(NSArray *)calendars
{
    if (!self.cacheDataSource) {
        return nil;
    }
    
    if (![self validateStartDate:startDate endDate:endDate]) {
        return nil;
    }
    
    // cache will only
    [self expandCacheIfNeededForStartDate:startDate endDate:endDate];
    
    return [self cachedEventsFrom:startDate to:endDate in:calendars];
}

- (BOOL)validateStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    if (!startDate) {
        DDLogError(@"Invalid Event Dates: Start date is nil");
        return NO;
    }
    
    if (!endDate) {
        DDLogError(@"Invalid Event Dates: End date is nil");
        return NO;
    }
    
    if ([startDate compare:endDate] != NSOrderedAscending) {
        DDLogError(@"Invalid Event Dates: Start date must be prior to end date");
        return NO;
    }
    
    return YES;
}


- (NSArray*)cachedEventsFrom:(NSDate*)startDate to:(NSDate*)endDate in:(NSArray*)calendars
{
    NSRange eventsRange = [self rangeOfEventsFrom:startDate to:endDate];
    
    if (eventsRange.location != kEventsInRangeNotFound) {
        NSArray* eventsInRange = [self.events objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:eventsRange]];
        return [self filterEvents:eventsInRange inCalendars:calendars];
    } else { // no events found within the given date range
        return nil;
    }
}

- (NSRange)rangeOfEventsFrom:(NSDate*)startDate to:(NSDate*)endDate
{
    NSInteger startIndex = kEventsInRangeNotFound;
    
    for (int i = 0; i < self.events.count; i++) {
        EKEvent* current = self.events[i];
        if ([self event:current isInDateRangeFrom:startDate to:endDate]) {
            startIndex = i;
            break;
        }
    }
    
    if (startIndex >= 0) {
        NSInteger endIndex = startIndex;
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

- (NSArray*)filterEvents:(NSArray*)events inCalendars:(NSArray*)calendars
{
    if (calendars) {
        NSMutableArray* eventsInCalendars = [[NSMutableArray alloc] init];
        for (EKEvent* event in events) {
            // filter the events by calendar
            if ([calendars containsObject:event.calendar]) {
                [eventsInCalendars addObject:event];
            }
        }
        // match EKEventStore return scheme of nil when no events are found
        return (eventsInCalendars.count > 0) ? [eventsInCalendars copy] : nil;
    } else {
        return events;
    }
}

- (BOOL)event:(EKEvent*)event isInDateRangeFrom:(NSDate*)startDate to:(NSDate*)endDate
{
    BOOL startDateInRange = [event.startDate compare:startDate] != NSOrderedAscending &&
                            [event.startDate compare:endDate] == NSOrderedAscending;
    BOOL endDateInRange = [event.endDate compare:startDate] == NSOrderedDescending &&
                          [event.endDate compare:endDate] != NSOrderedDescending;
    
    return startDateInRange || endDateInRange;
}


#pragma mark - Managing events

- (void)addEvent:(EKEvent *)event
{
    [self.events addObject:event];
    self.events = [[self.events sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)] mutableCopy];
}

- (BOOL)removeEvent:(EKEvent *)event
{
    if ([self.events containsObject:event]) {
        [self.events removeObject:event];
        return YES;
    } else {
        DDLogWarn(@"Attempting to remove event that is not in cache");
        return NO;
    }
}

- (void)invalidateCache
{
    self.events = nil;
    self.cacheStartDate = nil;
    self.cacheEndDate = nil;
}

#pragma mark - Expanding cache

- (NSArray*)requestEventsFrom:(NSDate*)startDate to:(NSDate*)endDate
{
    NSArray* events = [self.cacheDataSource storedEventsFrom:startDate to:endDate];
    return [events sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
}

- (void)expandCacheIfNeededForStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    NSDate* expandStartDate = [startDate beginningOfMonth];
    NSDate* expandEndDate = [endDate endOfMonth];
    
    if (!self.cacheStartDate || !self.cacheEndDate) {
        // if either cache date is nil then cached events should be considered
        // invalid set both to the current expand date so the first call to add
        // events resets the cache to a valid state
        self.events = nil;
        self.cacheStartDate = expandEndDate;
        self.cacheEndDate = expandEndDate;
    }
  
    // the expanded start date is prior to current cache start date
    if ([expandStartDate compare:self.cacheStartDate] == NSOrderedAscending) {
        [self addEventsFromStartDate:expandStartDate endDate:self.cacheStartDate locationInCache:0];
        self.cacheStartDate = expandStartDate;
    }
    
    // the expanded end date is after the current cache end date
    if ([expandEndDate compare:self.cacheEndDate] == NSOrderedDescending) {
        [self addEventsFromStartDate:self.cacheEndDate endDate:expandEndDate locationInCache:self.events.count];
        self.cacheEndDate = expandEndDate;
    }
}

- (void)addEventsFromStartDate:(NSDate*)startDate endDate:(NSDate*)endDate locationInCache:(NSInteger)loc
{
    NSArray* storedEvents = [self.cacheDataSource storedEventsFrom:startDate to:endDate];
   
    if (storedEvents) { // don't insert nil elements
        NSIndexSet* eventsIndices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, storedEvents.count)];
        [self.events insertObjects:storedEvents atIndexes:eventsIndices];
    }
}

@end
