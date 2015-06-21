//
//  ECDateViewFactory.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECDateView;

@interface ECDateViewFactory : NSObject

//------------------------------------------------------------------------------
// @name Creating Date Views
//------------------------------------------------------------------------------

/**
 *  Creates a new date view object for the given date with its date set
 *  according to the value of the date parameter and the appropriate accessory 
 *  views for the given date.
 *
 *  @param date The new date view's date
 *
 *  @return A newly created date view with the given date
 */
- (ECDateView*)dateViewForDate:(NSDate*)date;

/**
 *  Creates an array of date views for the given dates by reusing views where 
 *  possible and creating new views when necessary.
 *
 *  @param dates         The dates for which to create date views
 *  @param reusableViews An array of date views which can be reconfigured
 *
 *  @return An array of date views for the given dates
 */
- (NSArray*)dateViewsForDates:(NSArray*)dates reusingViews:(NSArray*)reusableViews;

//------------------------------------------------------------------------------
// @name Calendar Icons
//------------------------------------------------------------------------------

/**
 *  Creates an array of calendar icons for the given EKCalendar objects by 
 *  reusing icons when possible and creating new icons when necessary.
 *
 *  @param calendars An array of EKCalendars to create icons for
 *
 *  @return An array of calendar icons representing the given calendars
 */
- (NSArray*)calendarIconsForCalendars:(NSArray*)calendars reusingViews:(NSArray*)reusableViews;

@end
