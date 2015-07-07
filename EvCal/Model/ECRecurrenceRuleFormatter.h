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
- (nonnull NSString*)stringFromRecurrenceRule:(nonnull ECRecurrenceRule*)rule;

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
