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
@property (nonatomic, strong, readonly) NSString* __nonnull quarterHourAlarmLocalizedName; // 15 Minutes Before
// The localized name for an alarm thirty minutes prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull halfHourLocalizedName; // 30 Minutes Before
// The localized name for an alarm one hour prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull oneHourLocalizedName; // One Hour Before
// The localized name for an alarm two hours prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull twoHoursLocalizedName; // Two Hours Before
// The localized name for an alarm six hours prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull sixHoursLocalizedName; // Six Hours Before
// The localized name for an alarm one day prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull oneDayLocalizedName; // One Day Before
// The localized name for an alarm two days prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull twoDaysLocalizedName; // Two Days Before
// The localized name for an alarm with a custom offset prior to an event.
@property (nonatomic, strong, readonly) NSString* __nonnull customOffsetLocalizedName; // [Offset] Before
// The localized name for an alarm with an absolute fire date.
@property (nonatomic, strong, readonly) NSString* __nonnull absoluteDateLocalizedName; // July 4th, 2015, 10:00PM
// An array of all the formatter's localized names.
@property (nonatomic, strong, readonly) NSArray* __nonnull localizedNames;

//------------------------------------------------------------------------------
// @name Creating localized strings
//------------------------------------------------------------------------------

/**
 *  Creates and returns a new localized string for the given alarm.
 *
 *  @param alarm The alarm for which to create a string.
 *
 *  @return The newly created string.
 */
- (nonnull NSString*)localizedStringFromAlarm:(nonnull ECAlarm*)alarm;

/**
 *  Creates and returns a new localized string for the given alarm type.
 *
 *  @param alarmType The alarm type for which to create a string.
 *
 *  @return The newly created string.
 */
- (nonnull NSString*)localizedAlarmNameForType:(ECAlarmType)alarmType;

@end
