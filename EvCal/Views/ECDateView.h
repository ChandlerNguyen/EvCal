//
//  ECDateView.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDateView : UIControl

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date displayed by the date view, only the day is significant
@property (nonatomic, strong) NSDate* date;
// Determines whether the date view represents the selected date
@property (nonatomic, getter=isSelectedDate, readonly) BOOL selectedDate;
// Determines whether the date view is the same day as the current date
@property (nonatomic, getter=isTodaysDate) BOOL todaysDate;
// The calendars with events in the given date.
@property (nonatomic, strong) NSArray* calendars;

/**
 *  Sets the receiver's date to the given value.
 *
 *  @param selectedDate The new value for selectedDate
 *  @param animated     Determines whether any visible transitions should be 
 *                      animated
 */
- (void)setSelectedDate:(BOOL)selectedDate animated:(BOOL)animated;

//------------------------------------------------------------------------------
// @name Initializing
//------------------------------------------------------------------------------

/**
 *  DESIGNATED INITIALIZER
 *  Creates a new date view with the given date.
 *
 *  @param date The date with which to initialize the view.
 *
 *  @return A newly created date view with the given date.
 */
- (instancetype)initWithDate:(NSDate*)date;

@end
