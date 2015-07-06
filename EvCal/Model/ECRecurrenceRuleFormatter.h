//
//  ECRecurrenceRuleFormatter.h
//  EvCal
//
//  Created by Tom on 7/6/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EKRecurrenceRule;

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
     *  Event repeats every other week
     */
    ECRecurrenceRuleTypeBiweekly, // @"Every 2 Weeks"
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
 *  ECRecurrenceRuleTypeCustom.
 *
 *  @param type The type of recurrence to be created.
 *
 *  @return A newly created EKRecurrenceRule.
 */
- (EKRecurrenceRule*)recurrenceRuleForRecurrenceType:(ECRecurrenceRuleType)type;

/**
 *  Returns the type of the recurrence rule.
 *
 *  @param rule The rule for which to return a type.
 *
 *  @return The type of the recurrence rule.
 */
- (ECRecurrenceRuleType)typeForRecurrenceRule:(EKRecurrenceRule*)rule;


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
- (NSString*)stringFromRecurrenceRule:(EKRecurrenceRule*)rule;

/**
 *  Creates and returns a string based on the recurrence type. The strings will
 *  be localized versions of the strings defined for the different recurrence
 *  types.
 *
 *  @param type The type of recurrence for which to create a string.
 *
 *  @return A newly created string representation of the type.
 */
- (NSString*)stringFromRecurrenceType:(ECRecurrenceRuleType)type;

@end
