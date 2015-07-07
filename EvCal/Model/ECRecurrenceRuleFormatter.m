//
//  ECRecurrenceRuleFormatter.m
//  EvCal
//
//  Created by Tom on 7/6/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECRecurrenceRuleFormatter.h"


@implementation ECRecurrenceRuleFormatter
NSString* const __nonnull ECRecurrenceRuleNameDaily =       @"ECRecurrenceRule.Daily";
NSString* const __nonnull ECRecurrenceRuleNameWeekdays =    @"ECRecurrenceRule.Weekdays";
NSString* const __nonnull ECRecurrenceRuleNameWeekly =      @"ECRecurrenceRule.Weekly";
NSString* const __nonnull ECRecurrenceRuleNameMonthly =     @"ECRecurrenceRule.Monthly";
NSString* const __nonnull ECRecurrenceRuleNameYearly =      @"ECRecurrenceRule.Yearly";
NSString* const __nonnull ECRecurrenceRuleNameCustom =      @"ECRecurrenceRule.Custom";

static NSArray* weekdays = nil;
+ (NSArray*)weekdays
{
    if (!weekdays) {
        weekdays = @[[EKRecurrenceDayOfWeek dayOfWeek:EKMonday],
                     [EKRecurrenceDayOfWeek dayOfWeek:EKTuesday],
                     [EKRecurrenceDayOfWeek dayOfWeek:EKWednesday],
                     [EKRecurrenceDayOfWeek dayOfWeek:EKThursday],
                     [EKRecurrenceDayOfWeek dayOfWeek:EKFriday]];
    }
    
    return weekdays;
}

- (EKRecurrenceRule*)recurrenceRuleForRecurrenceType:(ECRecurrenceRuleType)type
{
    switch (type) {
        case ECRecurrenceRuleTypeDaily:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:nil];
            
        case ECRecurrenceRuleTypeWeekly:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 end:nil];
            
        case ECRecurrenceRuleTypeMonthly:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:1 end:nil];
            
        case ECRecurrenceRuleTypeYearly:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 end:nil];
            
        case ECRecurrenceRuleTypeWeekdays:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                                                interval:1
                                                           daysOfTheWeek:[ECRecurrenceRuleFormatter weekdays]
                                                          daysOfTheMonth:nil
                                                         monthsOfTheYear:nil
                                                          weeksOfTheYear:nil
                                                           daysOfTheYear:nil
                                                            setPositions:nil
                                                                     end:nil];
            
        // The customRecurrenceRuleWithFrequency:interval: method should be returned
        case ECRecurrenceRuleTypeCustom:
        default:
            DDLogWarn(@"Attempting to create custom recurrence rule wihtout sepcifying parameters");
            return nil;
    }
}

- (EKRecurrenceRule*)customRecurrenceRuleWithFrequency:(EKRecurrenceFrequency)frequency interval:(NSInteger)interval
{
    return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency interval:interval end:nil];
}

- (ECRecurrenceRuleType)typeForRecurrenceRule:(nonnull EKRecurrenceRule *)rule
{
    if (!rule) {
        NSException* invalidArgumentException = [NSException exceptionWithName:NSInvalidArgumentException reason:@"Recurrence rule should not be nil" userInfo:nil];
        [invalidArgumentException raise];
    }
    
    
    switch (rule.frequency) {
        case EKRecurrenceFrequencyDaily:
            return [self typeForDailyRecurrenceRule:rule];
            
        case EKRecurrenceFrequencyWeekly:
            return [self typeForWeeklyRecurrenceRule:rule];
            
        case EKRecurrenceFrequencyMonthly:
            return [self typeForMonthlyRecurrenceRule:rule];
            
        case EKRecurrenceFrequencyYearly:
            return [self typeForYearlyRecurrenceRule:rule];
            
        default: {
            NSException* invalidArgumentException = [NSException exceptionWithName:NSInvalidArgumentException reason:@"Recurrence rule has unrecognized frequency type" userInfo:@{@"Recurrence Rule":rule}];
            [invalidArgumentException raise];
        }
    }
}

- (ECRecurrenceRuleType)typeForDailyRecurrenceRule:(EKRecurrenceRule*)rule
{
    if (rule.interval == 1 &&
        ![self recurrenceRuleHasSpecificDays:rule]) {
        return ECRecurrenceRuleTypeDaily;
    } else {
        return ECRecurrenceRuleTypeCustom;
    }
}

- (ECRecurrenceRuleType)typeForWeeklyRecurrenceRule:(EKRecurrenceRule*)rule
{
    if (rule.interval == 1 &&
        ![self recurrenceRuleHasSpecificDays:rule]) {
        return ECRecurrenceRuleTypeWeekly;
    } else if (rule.interval == 1 &&
               !rule.daysOfTheMonth &&
               !rule.daysOfTheYear &&
               [rule.daysOfTheWeek isEqualToArray:[ECRecurrenceRuleFormatter weekdays]]) {
        return ECRecurrenceRuleTypeWeekdays;
    } else {
        return ECRecurrenceRuleTypeCustom;
    }
}

- (ECRecurrenceRuleType)typeForMonthlyRecurrenceRule:(EKRecurrenceRule*)rule
{
    if (rule.interval == 1 &&
        ![self recurrenceRuleHasSpecificDays:rule]) {
        return ECRecurrenceRuleTypeMonthly;
    } else {
        return ECRecurrenceRuleTypeCustom;
    }
}

- (ECRecurrenceRuleType)typeForYearlyRecurrenceRule:(EKRecurrenceRule*)rule
{
    if (rule.interval == 1 &&
        ![self recurrenceRuleHasSpecificDays:rule]) {
        return ECRecurrenceRuleTypeYearly;
    } else {
        return ECRecurrenceRuleTypeCustom;
    }
}

- (BOOL)recurrenceRuleHasSpecificDays:(EKRecurrenceRule*)rule
{
    return rule.daysOfTheWeek || rule.daysOfTheMonth || rule.daysOfTheYear;
}

- (NSString*)stringFromRecurrenceType:(ECRecurrenceRuleType)type
{
    switch (type) {
        case ECRecurrenceRuleTypeDaily:
            return NSLocalizedString(ECRecurrenceRuleNameDaily, @"The event repeats every day");
            
        case ECRecurrenceRuleTypeWeekdays:
            return NSLocalizedString(ECRecurrenceRuleNameWeekdays, @"The event repeats only on weekdays");
            
        case ECRecurrenceRuleTypeWeekly:
            return NSLocalizedString(ECRecurrenceRuleNameWeekly, @"The event repeats on the same day every week");
        
        case ECRecurrenceRuleTypeMonthly:
            return NSLocalizedString(ECRecurrenceRuleNameMonthly, @"The event repeats on the same date every month");
            
        case ECRecurrenceRuleTypeYearly:
            return NSLocalizedString(ECRecurrenceRuleNameYearly, @"The event repeats on the same date every year");
            
        case ECRecurrenceRuleTypeCustom:
            return NSLocalizedString(ECRecurrenceRuleNameCustom, @"The event repeats on a schedule that is not defined above");
            
        default: {
            NSException* invalidArugmentException = [NSException exceptionWithName:NSInvalidArgumentException reason:@"The recurrence type is not recognized" userInfo:nil];
            [invalidArugmentException raise];
        }
            
    }
}

- (NSString*)stringFromRecurrenceRule:(nullable EKRecurrenceRule *)rule
{
    return [self stringFromRecurrenceType:[self typeForRecurrenceRule:rule]];
}

@end
