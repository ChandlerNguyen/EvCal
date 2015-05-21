//
//  NSDate+ECTestAdditions.h
//  EvCal
//
//  Created by Tom on 5/21/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ECTestAdditions)

//------------------------------------------------------------------------------
// @name Creating Random Dates
//------------------------------------------------------------------------------

/**
 *  Creates a new date object with the first second of a random day within the 
 *  previous 2 and next 2 years (not accounting for leap years).
 *
 *  @return A newly created date object that lies within the previous and next
 *          2 years.
 */
+ (NSDate*)randomDate;

@end
