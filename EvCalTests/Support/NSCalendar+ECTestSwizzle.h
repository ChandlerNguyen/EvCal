//
//  NSCalendar+ECTestSwizzle.h
//  EvCal
//
//  Created by Tom on 5/27/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (ECTestSwizzle)

//------------------------------------------------------------------------------
// @name Swizzling
//------------------------------------------------------------------------------

/**
 *  Swizzles the default currentCalendar implementation with an implementation
 *  that uses New York's time zone. This allows date based tests to be tested
 *  against daylight savings regardless of the settings on the device or
 *  simulator to which the test is attached.
 */
+ (void)swizzleDaylightSavingTimeZone;

@end
