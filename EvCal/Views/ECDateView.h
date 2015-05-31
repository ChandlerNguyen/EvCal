//
//  ECDateView.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDateView : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date displayed by the date view, only the day is significant
@property (nonatomic, strong) NSDate* date;
// Determines whether the date view represents the selected date
@property (nonatomic, getter=isSelectedDate, readonly) BOOL selectedDate;
// Determines whether the date view is the same day as the current date
@property (nonatomic, getter=isTodaysDate) BOOL todaysDate;
// Any additional views within the date view representing user events in the
// view's date
@property (nonatomic, strong) NSArray* eventAccessoryViews;

/**
 *  Sets the receiver's date to the given value.
 *
 *  @param selectedDate The new value for selectedDate
 *  @param animated     Determines whether any visible transitions should be 
 *                      animated
 */
- (void)setSelectedDate:(BOOL)selectedDate animated:(BOOL)animated;

@end
