//
//  ECRecurrenceRuleFormatter.h
//  EvCal
//
//  Created by Tom on 7/6/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECRecurrenceRule.h"

@interface ECRecurrenceRuleFormatter : NSObject

//------------------------------------------------------------------------------
// @name Initializing formatter instances
//------------------------------------------------------------------------------

/**
 *  Returns a default instance of the recurrence formatter. This is a shared
 *  instance, and is provided primarily for efficiency reasons. No guarantees
 *  are made about its behavior in a multi-threaded environment.
 *
 *  @return The default formatter instance.
 */
+ (nonnull instancetype)defaultFormatter;


//------------------------------------------------------------------------------
// @name Creating strings
//------------------------------------------------------------------------------

// The following string properties are localized names for the different rules.
// Each copy of a formatter maintains its own copy of these strings.
@property (nonatomic, strong, readonly) NSString* __nonnull noneRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull dailyRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull weekdaysRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull weeklyRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull monthlyRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull yearlyRuleName;
@property (nonatomic, strong, readonly) NSString* __nonnull customRuleName;

// All of the recurrence rule names
@property (nonatomic, strong, readonly) NSArray* __nonnull ruleNames;

/**
 *  Creates and returns a string based on the recurrence rule. The string will 
 *  be localized versions of the strings defined for the different recurrence
 *  types.
 *
 *  @param rule The recurrence rule for which to create a string.
 *
 *  @return A newly created string representation of the rule.
 */
- (nonnull NSString*)stringFromRecurrenceRule:(nonnull ECRecurrenceRule*)rule;

/**
 *  Creates and returns a string explaning the given recurrence rule. For
 *  a recurrence rule with an interval of 2 and a frequency of daily would
 *  return a value of "Repeats every 2 days" for an English localization.
 *
 *  @param rule The rule to be described by the string.
 *
 *  @return A newly created string describing the given rule.
 */
- (nonnull NSString*)detailStringFromRecurrenceRule:(nonnull ECRecurrenceRule*)rule;

/**
 *  Creates and returns a string based on the recurrence type. The strings are 
 *  localized upon creation.
 *
 *  @param type The type of recurrence for which to create a string.
 *
 *  @return A newly created string representation of the type.
 */
- (nonnull NSString*)stringFromRecurrenceType:(ECRecurrenceRuleType)type;

@end
