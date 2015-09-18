//
//  NSDate+ECEventAdditions.h
//  EvCal
//
//  Created by Tom on 6/7/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ECEventAdditions)

//------------------------------------------------------------------------------
// @name Combining Dates
//------------------------------------------------------------------------------

/**
 *  Creates a new date by combining the era, year, month, and day of the 
 *  receiver and the hour, minute, and second of the time parameter.
 *
 *  @param time The date from which to draw the time
 *
 *  @return A newly created date object with the receiver's day and the given
 *          time.
 */
- (NSDate*)dateWithTimeOfDate:(NSDate*)time;

- (NSDate*)nearestFiveMinutes;

@end
