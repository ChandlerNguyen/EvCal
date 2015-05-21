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
