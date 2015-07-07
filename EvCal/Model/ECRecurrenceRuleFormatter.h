//
//  ECRecurrenceRuleFormatter.h
//  EvCal
//
//  Created by Tom on 7/6/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EKRecurrenceRule;

// A set of nonlocalized strings
extern NSString* const __nonnull ECRecurrenceRuleNameDaily;
extern NSString* const __nonnull ECRecurrenceRuleNameWeekdays;
extern NSString* const __nonnull ECRecurrenceRuleNameWeekly;
extern NSString* const __nonnull ECRecurrenceRuleNameMonthly;
extern NSString* const __nonnull ECRecurrenceRuleNameYearly;
extern NSString* const __nonnull ECRecurrenceRuleNameCustom;

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

@interface ECRecurrenceRuleFormatter : NSObject

//------------------------------------------------------------------------------
// @name Creating recurrence rules
//------------------------------------------------------------------------------

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
- (nullable EKRecurrenceRule*)recurrenceRuleForRecurrenceType:(ECRecurrenceRuleType)type;

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
- (nullable EKRecurrenceRule*)customRecurrenceRuleWithFrequency:(EKRecurrenceFrequency)frequency interval:(NSInteger)interval;

/**
 *  Returns the type of the recurrence rule.
 *
 *  @param rule The rule for which to return a type.
 *
 *  @return The type of the recurrence rule.
 */
- (ECRecurrenceRuleType)typeForRecurrenceRule:(nonnull EKRecurrenceRule*)rule;


//------------------------------------------------------------------------------
// @name Creating strings
//------------------------------------------------------------------------------

/**
 *  Creates and returns a string based on the recurrence rule. The string will 
 *  be localized versions of the strings defined for the different recurrence
 *  types.
 *
 *  @param rule The recurrence rule for which to create a string.
 *
 *  @return A newly created string representation of the rule.
 */
- (nullable NSString*)stringFromRecurrenceRule:(nullable EKRecurrenceRule*)rule;

/**
 *  Creates and returns a string based on the recurrence type. The strings will
 *  be localized versions of the strings defined for the different recurrence
 *  types.
 *
 *  @param type The type of recurrence for which to create a string.
 *
 *  @return A newly created string representation of the type.
 */
- (nullable NSString*)stringFromRecurrenceType:(ECRecurrenceRuleType)type;

@end
