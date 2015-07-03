//
//  ECEventCache.h
//  EvCal
//
//  Created by Tom on 6/30/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECEventCache;
@protocol ECEventCacheDataSource <NSObject>

/**
 *  Requests all events from the user's permanent event storage within the given
 *  date range.
 *
 *  @param startDate The beginning of the date range to search for events within.
 *  @param endDate   The end of the date range to search for events within.
 *
 *  @return An array of EKEvents or nil if no events fall within the range.
 */
- (NSArray*)storedEventsFrom:(NSDate*)startDate to:(NSDate*)endDate;

@end

@interface ECEventCache : NSObject

// The data source is responsible for providing events from the permamant store.
@property (nonatomic, weak) id<ECEventCacheDataSource> cacheDataSource;

/**
 *  Returns an array of events within the given date range in the given
 *  calendars.
 *
 *  @param startDate The start date of the date range to search within
 *  @param endDate   The end date of the date range to search within
 *  @param calendars The calendars whose events should be included
 *
 *  @return The newly created array of events or nil if no events could be 
 *          found. This method will always return nil if the receiver's data 
 *          source is not set.
 */
- (NSArray*)eventsFrom:(NSDate*)startDate to:(NSDate*)endDate in:(NSArray*)calendars;

/**
 * Tells the cache that it must reload events from the long term store
 */
- (void)invalidateCache;

@end
