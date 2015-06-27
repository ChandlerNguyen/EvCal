//
//  ECWeekdayPicker.h
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECWeekdayPicker;

//------------------------------------------------------------------------------
// @name ECWeekdayPicker data source
//------------------------------------------------------------------------------

@protocol ECWeekdayPickerDataSource <NSObject>

/**
 *  Requests the calendars to present in a given date view.
 *
 *  @param date The date for which to provide calendars
 *
 *  @return The calendar icons for the given date.
 */
- (NSArray*)calendarsForDate:(NSDate*)date;

@end

//------------------------------------------------------------------------------
// @name ECWeekdayPicker Delegate
//------------------------------------------------------------------------------

@protocol ECWeekdayPickerDelegate <NSObject>

@optional
/**
 *  Tells the delegate when a new weekday is selected in the picker view.
 *
 *  @param picker The picker in which the selection occurred
 *  @param date   The date selected
 */
- (void)weekdayPicker:(ECWeekdayPicker*)picker didSelectDate:(NSDate*)date;

@end

@interface ECWeekdayPicker : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The picker's currently selected date
@property (nonatomic, strong, readonly) NSDate* selectedDate;

/**
 *  Change the selected date of the receiver with or without an animation. If
 *  the date is not in the same day as any of the current weekdays a call will
 *  be made to the receiver's scrollToWeekContainingDate: method.
 *
 *  @param selectedDate The new selected date value
 *  @param animated     Determines whether the change should be animated
 */
- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated;

// An ordered week of dates
@property (nonatomic, strong, readonly) NSArray* weekdays;

// The delegate that will receive updates about picker events
@property (nonatomic, weak) id<ECWeekdayPickerDelegate> pickerDelegate;
@property (nonatomic, weak) id<ECWeekdayPickerDataSource> pickerDataSource;


//------------------------------------------------------------------------------
// @name Creating pickers
//------------------------------------------------------------------------------

/**
 *  DESIGNATED INITIALIZER
 *  Creates a new ECWeekdayPicker with its dates consisting of the days in the
 *  week containing the given date.
 *
 *  @param date A date that falls within the desired display week
 *
 *  @return A newly created ECWeekdayPicker with its weekdays set
 */
- (instancetype)initWithDate:(NSDate*)date;


//------------------------------------------------------------------------------
// @name Updating picker's displayed dates
//------------------------------------------------------------------------------

/**
 *  Changes the receiver's weekdays to those of the week containing the given 
 *  date.
 *
 *  @param date The date in the week that the receiver should display.
 */
- (void)scrollToWeekContainingDate:(NSDate*)date;

/**
 *  Refreshes the weekdays of the current selected date by reloading any date
 *  based data.
 */
- (void)refreshWeekdays;

/**
 *  Refreshes the view representing the day of the date by reloading any date
 *  based data.
 */
- (void)refreshWeekdayWithDate:(NSDate*)date;

@end
