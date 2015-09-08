//
//  ECMonthView.h
//  EvCal
//
//  Created by Tom on 9/4/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECMonthView;

@protocol ECMonthViewDelegate <NSObject>

@optional

/**
 *  Informs the delegate that a date was selected within the month view
 *
 *  @param monthView The month view within which a date was selected.
 *  @param date      The date that was selected.
 */
- (void)monthView:(ECMonthView* __nonnull)monthView didSelectDate:(NSDate* __nonnull)date;

@end

@interface ECMonthView : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date currently selected in the month view. A nil value means no date is selected
@property (nonatomic, strong) NSDate* __nullable selectedDate; // default is nil

// The days of the month represented by the month view. Use the initWithDate:
// method to automatically create days of month.
@property (nonatomic, strong) NSArray* __nonnull daysOfMonth; // defaults to days of current month

// The delegate to receive date selection messages.
@property (nonatomic, weak) id<ECMonthViewDelegate> __nullable monthViewDelegate; // default is nil

//------------------------------------------------------------------------------
// @name Initialization
//------------------------------------------------------------------------------

/**
 *  DESIGNATED INITIALIZER
 *  Initializes a new month view with the days of the month for the given date
 *  and a frame of CGRectZero.
 *
 *  @param date Any date within the desired month for the month view.
 *
 *  @return The newly created month view.
 */
- (nonnull instancetype)initWithDate:(nonnull NSDate*)date;


/**
 *  Initializes a new month view the days of the month for the given date and
 *  the selectedDate property set to the same day as the given date.
 *
 *  @param selectedDate The date to be selected when month view is presented.
 *
 *  @return The newly created month view.
 */
- (nonnull instancetype)initWithSelectedDate:(nonnull NSDate*)selectedDate;


//------------------------------------------------------------------------------
// @name Updating Dates
//------------------------------------------------------------------------------

/**
 *  Causes the receiver to update its layout. This includes changing the current
 *  date.
 */
- (void)updateDates;

@end
