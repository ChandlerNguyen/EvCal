//
//  NSArray+ECTesting.h
//  EvCal
//
//  Created by Tom on 5/19/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class EKEvent;
#import <Foundation/Foundation.h>

@interface NSArray (ECTesting)

//------------------------------------------------------------------------------
// @name Searching test elements from arrays
//------------------------------------------------------------------------------

/**
 *  Finds and returns the event with the given identifier.
 *
 *  @param identifier THe identifier of the event to be returned.
 *
 *  @return The event with the given identifier or nil if it cannot be found.
 */
- (EKEvent*)eventWithIdentifier:(NSString*)identifier;

/**
 *  Calculates the index of the element in the receiver in the same day as the
 *  given date by calling NSCalendar's isDate:inSameDayAsDate: method on each
 *  element in the receiver. The receiver must be an array consisting entirely
 *  of NSDate elements.
 *
 *  @param date The date to compare dates within the array against
 *
 *  @return The index of the first element in the same day as the given date
 *          or NSNotFound if no such element exists.
 */
- (NSUInteger)indexOfDateInSameDayAsDate:(NSDate*)date;

//------------------------------------------------------------------------------
// @name Comparing Arrays
//------------------------------------------------------------------------------

/**
 *  Convenience method for comparing arrays of events
 *
 *  @param left  One of the arrays to compare
 *  @param right The other array to compare
 *
 *  @return YES if the arrays contain all the same events, NO otherwise
 */
+ (BOOL)eventsArray:(NSArray*)left isSameAsArray:(NSArray*)right;

/**
 *  Returns true if the recevier has the same elements as the other array, even
 *  if those elements are in a different order.
 *
 *  @param other The array with which to compare the receiver
 *
 *  @return YES if the receiver has the same elements, NO otherwise
 */
- (BOOL)hasSameElements:(NSArray*)other;

@end
