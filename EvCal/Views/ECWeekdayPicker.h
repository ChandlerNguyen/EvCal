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

@interface ECWeekdayPicker : UIControl

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The picker's currently selected date
@property (nonatomic, strong) NSDate* selectedDate;

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
