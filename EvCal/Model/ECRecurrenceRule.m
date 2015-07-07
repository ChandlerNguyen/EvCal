//
//  ECRecurrenceRule.m
//  EvCal
//
//  Created by Tom on 7/7/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECRecurrenceRule.h"
#import "ECRecurrenceRuleFormatter.h"

@implementation ECRecurrenceRule

- (NSString*)localizedName
{
    return [[ECRecurrenceRuleFormatter defaultFormatter] stringFromRecurrenceType:self.type];
}

#pragma mark - Creating recurrence rules

- (instancetype)initWithRecurrenceRule:(EKRecurrenceRule *)rule
{
    if (!rule) {
        NSException* invalidArgumentException = [NSException exceptionWithName:NSInvalidArgumentException reason:@"ECRecurrenceRules must have EKRecurrenceRules" userInfo:nil];
        [invalidArgumentException raise];
    }
    
    self = [super init];
    if (self ) {
        _rule = rule;
    }
    
    return self;
}

static NSArray* weekdays = nil;
+ (ECRecurrenceRule*)recurrenceRuleForRecurrenceType:(ECRecurrenceRuleType)type
{
    EKRecurrenceRule* recurrenceRule = nil;
    switch (type) {
        case ECRecurrenceRuleTypeDaily:
            recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:nil];
            break;
            
        case ECRecurrenceRuleTypeWeekly:
            recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 end:nil];
            break;
            
        case ECRecurrenceRuleTypeMonthly:
            recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:1 end:nil];
            break;
            
        case ECRecurrenceRuleTypeYearly:
            recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 end:nil];
            break;
            
        case ECRecurrenceRuleTypeWeekdays:
            recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                                                          interval:1
                                                                     daysOfTheWeek:[ECRecurrenceRule weekdays]
                                                                    daysOfTheMonth:nil
                                                                   monthsOfTheYear:nil
                                                                    weeksOfTheYear:nil
                                                                     daysOfTheYear:nil
                                                                      setPositions:nil
                                                                               end:nil];
            break;
            
        case ECRecurrenceRuleTypeCustom:
            DDLogWarn(@"Custom recurrence rules should be created with the customRecurrenceRuleWithFrequency:interval: method");
            return nil;
        default:
            DDLogWarn(@"Unrecognized recurrence rule type received");
            return nil;
    }
    
    return [[ECRecurrenceRule alloc] initWithRecurrenceRule:recurrenceRule];
}

+ (ECRecurrenceRule*)customRecurrenceRuleWithFrequency:(EKRecurrenceFrequency)frequency interval:(NSInteger)interval
{
    EKRecurrenceRule* recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency interval:interval end:nil];
    return [[ECRecurrenceRule alloc] initWithRecurrenceRule:recurrenceRule];
}

- (ECRecurrenceRuleType)type
{
    if (!self.rule) {
        NSException* internalInconsistencyException = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ECRecurrenceRule's recurrence rule should not be nil" userInfo:nil];
        [internalInconsistencyException raise];
    }
    
    switch (self.rule.frequency) {
        case EKRecurrenceFrequencyDaily:
            return [self typeForDailyRecurrenceRule:self.rule];
            
        case EKRecurrenceFrequencyWeekly:
            return [self typeForWeeklyRecurrenceRule:self.rule];
            
        case EKRecurrenceFrequencyMonthly:
            return [self typeForMonthlyRecurrenceRule:self.rule];
            
        case EKRecurrenceFrequencyYearly:
            return [self typeForYearlyRecurrenceRule:self.rule];
            
        default: {
            NSException* invalidArgumentException = [NSException exceptionWithName:NSInvalidArgumentException reason:@"Recurrence rule has unrecognized frequency type" userInfo:@{@"Recurrence Rule":self.rule}];
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
               [rule.daysOfTheWeek isEqualToArray:[ECRecurrenceRule weekdays]]) {
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

@end
