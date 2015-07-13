//
//  ECAlarmFormatter.h
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECAlarm.h"

@interface ECAlarmFormatter : NSObject
//------------------------------------------------------------------------------
// @name Creating formatters
//------------------------------------------------------------------------------

/**
 *  Returns the shared instance of ECAlarmFormatter. This method is provided for
 *  effieciency reasons to avoid the overhead of creating multiple formatters.
 *  This is a shared resource, no guarantees are made about its behavior in a 
 *  multi-threaded environment. Appropriate thread safety mechanisms should be 
 *  used in such an environment.
 *
 *  @return The default ECAlarmFormatter
 */
+ (nonnull instancetype)defaultFormatter;

//------------------------------------------------------------------------------
// @name Localized Names
//------------------------------------------------------------------------------

// The localized name for no alarms
@property (nonatomic, strong, readonly) NSString* __nonnull noneAlarmLocalizedName; // None
// The localized name for an alarm fifteen minutes prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull quarterHourAlarmLocalizedName; // 15 Minutes
// The localized name for an alarm thirty minutes prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull halfHourLocalizedName; // 30 Minutes
// The localized name for an alarm one hour prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull oneHourLocalizedName; // One Hour
// The localized name for an alarm two hours prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull twoHoursLocalizedName; // Two Hours
// The localized name for an alarm six hours prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull sixHoursLocalizedName; // Six Hours
// The localized name for an alarm one day prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull oneDayLocalizedName; // One Day
// The localized name for an alarm two days prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull twoDaysLocalizedName; // Two Days
// The localized name for an alarm with a custom offset
@property (nonatomic, strong, readonly) NSString* __nonnull customOffsetLocalizedName;
// The localized name for a date with an absolute date
@property (nonatomic, strong, readonly) NSString* __nonnull absoluteDateLocalizedName;

// An array of all the formatter's localized names.
@property (nonatomic, strong, readonly) NSArray* __nonnull localizedNames;

//------------------------------------------------------------------------------
// @name Creating localized strings
//------------------------------------------------------------------------------

/**
 *  Returns a localized string for the given alarm.
 *
 *  @param alarm The alarm for which to return a string.
 *
 *  @return A string describing the given alarm.
 */
- (nonnull NSString*)localizedStringFromAlarm:(nonnull ECAlarm*)alarm;

/**
 *  Creates and returns a new localized string for the given alarm type.
 *
 *  @param alarmType The type of alarm for which to create a string
 *
 *  @return The newly created string describing the alarm type.
 */
- (nonnull NSString*)localizedStringForAlarmType:(ECAlarmType)alarmType;

@end
