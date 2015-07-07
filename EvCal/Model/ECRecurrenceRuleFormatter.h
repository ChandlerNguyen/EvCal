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
// @name Initializing formatter instances
//------------------------------------------------------------------------------

/**
 *  Creates a new formatter instance with its localization property set to the 
 *  given value.
 *
 *  @param localizeStrings The value of the localizeStrings property
 *
 *  @return A newly created formatter with the given value of localize strings.
 */
- (nonnull instancetype)initUsingLocalization:(BOOL)localizeStrings;

/**
 *  Returns a default instance of the recurrence formatter. This is a shared
 *  instance, and should be used only for efficiency reasons. No guarantees are
 *  made about the thread safety of this formatter, so appropriate threading 
 *  safety should be used in a multi-threaded environment. One possbile side 
 *  effect of improper resource sharing would result in nil strings being
 *  returned from the stringFrom methods.
 *
 *  @return The default formatter instance.
 */
+ (nonnull instancetype)defaultFormatter;

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

// determines whether the formatter should localize strings. This value cannot
// be changed once the formatter is instantiated.
@property (nonatomic, readonly) BOOL localizeStrings; // default is YES

// The following strings are defined for each instance of a formatter. If the
// localizeStrings property is set to YES these strings will be localized. The
// unlocalized strings are listed next to each property.
@property (nonatomic, strong, readonly) NSString* __nonnull dailyRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull weekdaysRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull weeklyRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull monthlyRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull yearlyRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull customRuleName;

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
 *  Creates and returns a string based on the recurrence type. The strings are 
 *  localized upon creation.
 *
 *  @param type The type of recurrence for which to create a string.
 *
 *  @return A newly created string representation of the type.
 */
- (nullable NSString*)stringFromRecurrenceType:(ECRecurrenceRuleType)type;

@end