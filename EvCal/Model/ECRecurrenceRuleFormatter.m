//
//  ECRecurrenceRuleFormatter.m
//  EvCal
//
//  Created by Tom on 7/6/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECRecurrenceRuleFormatter.h"
@interface ECRecurrenceRuleFormatter()

@property (nonatomic, strong, readwrite) NSString* dailyRuleName;
@property (nonatomic, strong, readwrite) NSString* weekdaysRuleName;
@property (nonatomic, strong, readwrite) NSString* weeklyRuleName;
@property (nonatomic, strong, readwrite) NSString* monthlyRuleName;
@property (nonatomic, strong, readwrite) NSString* yearlyRuleName;
@property (nonatomic, strong, readwrite) NSString* customRuleName;

@end


@implementation ECRecurrenceRuleFormatter

#pragma mark - Initializing formatters

- (instancetype)initUsingLocalization:(BOOL)localizeStrings
{
    self = [super init];
    if (self) {
        self.localizeStrings = localizeStrings;
    }
    
    return self;
}

+ (instancetype)defaultFormatter
{
    static ECRecurrenceRuleFormatter* defaultFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultFormatter = [[ECRecurrenceRuleFormatter alloc] initUsingLocalization:YES];
    });
    
    return defaultFormatter;
}

#pragma mark - Recurrence rule strings

- (void)setLocalizeStrings:(BOOL)localizeStrings
{
    _localizeStrings = localizeStrings;
    [self nullifyStrings];
}

- (void)nullifyStrings
{
    _dailyRuleName = nil;
    _weekdaysRuleName = nil;
    _weeklyRuleName = nil;
    _monthlyRuleName = nil;
    _yearlyRuleName = nil;
    _customRuleName = nil;
}

- (NSString*)dailyRuleName
{
    if (!_dailyRuleName) {
        if (self.localizeStrings) {
            _dailyRuleName = NSLocalizedString(@"ECRecurrenceRule.Daily", @"The event repeats every day");
        } else {
            _dailyRuleName = @"ECRecurrenceRule.Daily";
        }
    }
    
    return _dailyRuleName;
}

- (NSString*)weekdaysRuleName
{
    if (!_weekdaysRuleName) {
        if (self.localizeStrings) {
            _weekdaysRuleName = NSLocalizedString(@"ECRecurrenceRule.Weekdays", @"The event repeats every weekday (not weekends)");
        } else {
            _weekdaysRuleName = @"ECRecurrenceRule.Weekdays";
        }
    }
    
    return _weekdaysRuleName;
}

- (NSString*)weeklyRuleName
{
    if (!_weeklyRuleName) {
        if (self.localizeStrings) {
            _weeklyRuleName = NSLocalizedString(@"ECRecurrenceRule.Weekly", @"The event repeats on the same day every week");
        } else {
            _weeklyRuleName = @"ECRecurrenceRule.Weekly";
        }
    }
    
    return _weeklyRuleName;
}

- (NSString*)monthlyRuleName
{
    if (!_monthlyRuleName) {
        if (self.localizeStrings) {
            _monthlyRuleName = NSLocalizedString(@"ECRecurrenceRule.Monthly", @"The event repeats on the same date every month");
        } else {
            _monthlyRuleName = @"ECRecurrenceRule.Monthly";
        }
    }
    
    return _monthlyRuleName;
}

- (NSString*)yearlyRuleName
{
    if (!_yearlyRuleName) {
        if (self.localizeStrings) {
            _yearlyRuleName = NSLocalizedString(@"ECRecurrenceRule.Yearly", @"The event repeats on the same date every year");
        } else {
            _yearlyRuleName = @"ECRecurrenceRule.Monthly";
        }
    }
    
    return _yearlyRuleName;
}

- (NSString*)customRuleName
{
    if (!_customRuleName) {
        if (self.localizeStrings) {
            _customRuleName = NSLocalizedString(@"ECRecurrenceRule.Custom", @"The event repeats on a custom schedule defined by the user");
        } else {
            _customRuleName = @"ECRecurrenceRule.Monthly";
        }
    }
    
    return _customRuleName;
}


#pragma mark - Creating recurrence rules

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
            return self.dailyRuleName;
            
        case ECRecurrenceRuleTypeWeekdays:
            return self.weekdaysRuleName;
            
        case ECRecurrenceRuleTypeWeekly:
            return self.weeklyRuleName;
        
        case ECRecurrenceRuleTypeMonthly:
            return self.monthlyRuleName;
            
        case ECRecurrenceRuleTypeYearly:
            return self.yearlyRuleName;
            
        case ECRecurrenceRuleTypeCustom:
            return self.customRuleName;
            
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
