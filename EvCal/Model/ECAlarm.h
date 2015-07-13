//
//  ECAlarm.h
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EKAlarm;

/**
 *  The predefined ECAlarm types. The English versions of their locazlied names
 *  are listed next to each enum constant.
 */
typedef NS_ENUM(NSInteger, ECAlarmType){
    /**
     *  The event has no alarm.
     */
    ECAlarmTypeNone, // None
    /**
     *  The event has an alarm 15 minutes prior to its start date.
     */
    ECAlarmTypeOffsetQuarterHour,
    /**
     *  The event has an alarmt 30 minutes prior to its start date.
     */
    ECAlarmTypeOffsetHalfHour,
    /**
     *  The event has an alarm one hour prior to its start date.
     */
    ECAlarmTypeOffsetHour,
    /**
     *  The event has an alarm two hours prior to its start date.
     */
    ECAlarmTypeOffsetTwoHours,
    /**
     *  The event has an alarm six hours prior to its start date.
     */
    ECAlarmTypeOffsetSixHours,
    /**
     *  The event has an alarm one day prior to its start date.
     */
    ECAlarmTypeOffsetOneDay,
    /**
     *  The event has an alarm two days prior to its start date.
     */
    ECAlarmTypeOffsetTwoDays,
    /**
     *  The event has an alarm at a custom offset prior to its start date.
     */
    ECAlarmTypeOffsetCustom,
    /**
     *  The event has an alarm set for an absolute date and time.
     */
    ECAlarmTypeAbsoluteDate,
};

@interface ECAlarm : NSObject

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The type of ECAlarm. See ECAlarmType constants for more details.
@property (nonatomic, readonly) ECAlarmType type;

// THe underlying alarm for the ECAlarm.
@property (nonatomic, strong) EKAlarm* __nullable ekAlarm;

// The localized name for the alarm. See ECAlarmFormatter for more information.
@property (nonatomic, strong, readonly) NSString* __nonnull localizedName;


//------------------------------------------------------------------------------
// @name Creating ECAlarms
//------------------------------------------------------------------------------

/**
 *  Creates a new ECAlarm with the given EKAlarm. The type and localizedName 
 *  properties will be populated accordingly.
 *
 *  @param ekAlarm The EKAlarm with which to create the ECAlarm.
 *
 *  @return The newly created ECAlarm.
 */
- (nonnull instancetype)initWithEKAlarm:(nullable EKAlarm*)ekAlarm;

/**
 *  Creates a new ECAlarm with the given type. The alarm's EKAlarm will be 
 *  automatically created as well. This method will throw an 
 *  NSInvalidArgumentException if ECAlarmTypeOffsetCustom or 
 *  ECAlarmTypeAbsoluteDate are passed in. Use the +alarmWithDate: or 
 *  -initWithEKAlarm: methods instead.
 *
 *  @param type The type of alarm to be created.
 *
 *  @return The newly created ECAlarm.
 */
+ (nonnull instancetype)alarmWithType:(ECAlarmType)type;

/**
 *  Creates a new ECAlarm with the given date. The alarm's EKAlarm will be
 *  automatically created. Throws an invalid arugment exception on nil date 
 *  input.
 *
 *  @param date The date with which to create the alarm.
 *
 *  @return The newly created ECAlarm.
 */
+ (nonnull instancetype)alarmWithDate:(nonnull NSDate*)date;

@end
