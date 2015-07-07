//
//  ECRecurrenceRule.h
//  EvCal
//
//  Created by Tom on 7/7/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import EventKit;

/**
 *  The recurrence rules defined by ECRecurrenceRuleFormatter
 */
typedef NS_ENUM(NSInteger, ECRecurrenceRuleType){
    /**
     *  Event repeats every day.
     */
    ECRecurrenceRuleTypeDaily, // @"Daily"
    /**
     *  Event repeats every weekday (excluding weekends).
     */
    ECRecurrenceRuleTypeWeekdays, // @"Every Weekday"
    /**
     *  Event repeats every week
     */
    ECRecurrenceRuleTypeWeekly, // @"Weekly"
    /**
     *  Event repeats every month
     */
    ECRecurrenceRuleTypeMonthly, // @"Monthly"
    /**
     *  Event repeats every year
     */
    ECRecurrenceRuleTypeYearly, // @"Yearly"
    /**
     *  Event repeats based on custom user rule
     */
    ECRecurrenceRuleTypeCustom, // @"Custom"
};

@interface ECRecurrenceRule : NSObject

// The underlying recurrence rule
@property (nonatomic, strong, readonly) EKRecurrenceRule* __nonnull rule;
// The defined type of the recurrence rule
@property (nonatomic, readonly) ECRecurrenceRuleType type;
// The localized name of the recurrence rule
@property (nonatomic, strong, readonly) NSString* __nonnull localizedName;

//------------------------------------------------------------------------------
// @name Creating recurrence rules
//------------------------------------------------------------------------------

- (nonnull instancetype)initWithRecurrenceRule:(nonnull EKRecurrenceRule*)rule;

/**
 *  Returns an EKRecurrenceRule for the given recurrence type. All recurrence
 *  types return a predefined recurrence rule except for
 *  ECRecurrenceRuleTypeCustom. Custom rules should be created using the
 *  customRuleWithFrequency:interval: method.
 *
 *  @param type The type of recurrence to be created.
 *
 *  @return A newly created EKRecurrenceRule or nil if the ECRecurrenceRuleType
 *          is not a valid value.
 */
+ (nullable ECRecurrenceRule*)recurrenceRuleForRecurrenceType:(ECRecurrenceRuleType)type;

/**
 *  Creates a custom recurrence rule with the given frequency and interval.
 *  If the frequency and interval of the custom recurrence rule match those of
 *  the predefined types the formatter will return strings and types for those
 *  predefined recurrences.
 *
 *  @param frequency The frequency of the recurrence rule. Check Apple's
 *                   EKRecurrenceFrequency documentation for possible values.
 *  @param interval  The interval when the event should be repeated. For example
 *                   a frequency of daily and an interval of 2 would occur every
 *                   other day.
 *
 *  @return The newly created recurrence rule.
 */
+ (nullable ECRecurrenceRule*)customRecurrenceRuleWithFrequency:(EKRecurrenceFrequency)frequency interval:(NSInteger)interval;


@end
