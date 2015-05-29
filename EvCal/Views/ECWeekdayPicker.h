//
//  ECWeekdayPicker.h
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECWeekdayPicker;
@protocol ECWeekdayPickerDelegate <NSObject>

- (void)weekdayPicker:(ECWeekdayPicker*)picker didSelectDate:(NSDate*)date;
- (void)weekdayPicker:(ECWeekdayPicker *)picker didScrollFrom:(NSArray*)fromWeek to:(NSArray*)toWeek;

@end

@interface ECWeekdayPicker : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// An ordered week of dates
@property (nonatomic, strong) NSArray* weekdays;

@property (nonatomic, weak) id<ECWeekdayPickerDelegate> pickerDelegate;


//------------------------------------------------------------------------------
// @name Creating pickers
//------------------------------------------------------------------------------

/**
 *  Creates a new ECWeekdayPicker with its dates consisting of the days in the
 *  week containing the given date.
 *
 *  @param date A date that falls within the desired display week
 *
 *  @return A newly created ECWeekdayPicker with its weekdays set
 */
- (instancetype)initWithDate:(NSDate*)date;

//------------------------------------------------------------------------------
// @name Changing pickers displayed dates
//------------------------------------------------------------------------------

- (void)scrollToWeekContainingDate:(NSDate*)date;

@end
