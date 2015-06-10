//
//  NSDateFormatter+ECAdditions.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (ECAdditions)

//------------------------------------------------------------------------------
// @name Creating contextual date formatters
//------------------------------------------------------------------------------

/**
 *  @return A date formatter with the proper regional formatting for date views
 *          within an ECWeekdayPicker.
 */
+ (instancetype)ecDateViewFormatter;

/**
 *  @return A date formatter with the proper regional formatting for start and
 *          end date labels associated with events.
 */
+ (instancetype)ecEventDatesFormatter;

@end
