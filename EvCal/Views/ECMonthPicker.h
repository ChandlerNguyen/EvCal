//
//  ECMonthPicker.h
//  EvCal
//
//  Created by Tom on 9/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECMonthPicker;
@protocol ECMonthPickerDelegate <NSObject>

@optional
/**
 *  Informs the delegate that a new date was selected within the month picker.
 *
 *  @param picker The picker within which a date was selected.
 *  @param date   The new selected date for the month picker.
 */
- (void)monthPicker:(nonnull ECMonthPicker*)picker didSelectDate:(nullable NSDate*)date;

@end

@interface ECMonthPicker : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The month picker's currently selected date. Setting this value will not cause
// the didSelectDate: delegate method to be called.
@property (nonatomic, strong) NSDate* __nullable selectedDate;

// The delegate for receiving month picker messages.
@property (nonatomic, weak) id<ECMonthPickerDelegate> __nullable monthPickerDelegate;


//------------------------------------------------------------------------------
// @name Initialization
//------------------------------------------------------------------------------

/**
 *  DESIGNATED INITIALIZER
 *  Initializes a new month picker view with the given selected date. The picker
 *  will display with the correct months for the given selected date.
 *
 *  @param date The selected date for the new month picker.
 *
 *  @return The newly created month picker.
 */
- (nonnull instancetype )initWithSelectedDate:(nullable NSDate*)date;

@end
