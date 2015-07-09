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

@property (nonatomic, strong, readwrite) NSArray* ruleNames;
@property (nonatomic, strong, readwrite) NSString* noneRuleName;
@property (nonatomic, strong, readwrite) NSString* dailyRuleName;
@property (nonatomic, strong, readwrite) NSString* weekdaysRuleName;
@property (nonatomic, strong, readwrite) NSString* weeklyRuleName;
@property (nonatomic, strong, readwrite) NSString* monthlyRuleName;
@property (nonatomic, strong, readwrite) NSString* yearlyRuleName;
@property (nonatomic, strong, readwrite) NSString* customRuleName;

@end


@implementation ECRecurrenceRuleFormatter

#pragma mark - Initializing formatters

+ (instancetype)defaultFormatter
{
    static ECRecurrenceRuleFormatter* defaultFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultFormatter = [[ECRecurrenceRuleFormatter alloc] init];
    });
    
    return defaultFormatter;
}

#pragma mark - Recurrence rule strings

- (NSArray*)ruleNames
{
    if (!_ruleNames) {
        _ruleNames = @[self.noneRuleName,
                       self.dailyRuleName,
                       self.weekdaysRuleName,
                       self.weeklyRuleName,
                       self.monthlyRuleName,
                       self.yearlyRuleName,
                       self.customRuleName];
    }
    
    return _ruleNames;
}

- (NSString*)noneRuleName
{
    if (!_noneRuleName) {
        _noneRuleName = NSLocalizedString(@"ECRecurrenceRule.None", @"The event never repeats");
    }
    
    return _noneRuleName;
}

- (NSString*)dailyRuleName
{
    if (!_dailyRuleName) {
        _dailyRuleName = NSLocalizedString(@"ECRecurrenceRule.Daily", @"The event repeats every day");
    }
    
    return _dailyRuleName;
}

- (NSString*)weekdaysRuleName
{
    if (!_weekdaysRuleName) {
        _weekdaysRuleName = NSLocalizedString(@"ECRecurrenceRule.Weekdays", @"The event repeats every weekday (not weekends)");
    }
    
    return _weekdaysRuleName;
}

- (NSString*)weeklyRuleName
{
    if (!_weeklyRuleName) {
        _weeklyRuleName = NSLocalizedString(@"ECRecurrenceRule.Weekly", @"The event repeats on the same day every week");
    }
    
    return _weeklyRuleName;
}

- (NSString*)monthlyRuleName
{
    if (!_monthlyRuleName) {
        _monthlyRuleName = NSLocalizedString(@"ECRecurrenceRule.Monthly", @"The event repeats on the same date every month");
    }
    
    return _monthlyRuleName;
}

- (NSString*)yearlyRuleName
{
    if (!_yearlyRuleName) {
        _yearlyRuleName = NSLocalizedString(@"ECRecurrenceRule.Yearly", @"The event repeats on the same date every year");
    }
    
    return _yearlyRuleName;
}

- (NSString*)customRuleName
{
    if (!_customRuleName) {
        _customRuleName = NSLocalizedString(@"ECRecurrenceRule.Custom", @"The event repeats on a custom schedule defined by the user");
    }
    return _customRuleName;
}

- (NSString*)stringFromRecurrenceType:(ECRecurrenceRuleType)type
{
    switch (type) {
        case ECRecurrenceRuleTypeNone:
            return self.noneRuleName;
            
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

- (NSString*)stringFromRecurrenceRule:(ECRecurrenceRule *)rule
{
    return [self stringFromRecurrenceType:rule.type];
}

- (NSString*)detailStringFromRecurrenceRule:(nonnull ECRecurrenceRule *)rule
{
    switch (rule.type) {
        case ECRecurrenceRuleTypeNone:
            return NSLocalizedString(@"ECRecurrenceRule.Never repeats", @"The event does not repeat");
            
        case ECRecurrenceRuleTypeDaily:
            return NSLocalizedString(@"ECRecurrenceRule.Repeats every day", @"The event repeats every day");
            
        case ECRecurrenceRuleTypeWeekdays:
            return NSLocalizedString(@"ECRecurrenceRule.Repeats every weekday", @"The event repeats every weekday");
            
        case ECRecurrenceRuleTypeWeekly:
            return NSLocalizedString(@"ECRecurrenceRule.Repeats every week", @"The event repeats every week");
            
        case ECRecurrenceRuleTypeMonthly:
            return NSLocalizedString(@"ECRecurrenceRule.Repeats every month", @"The event repeats every month");
            
        case ECRecurrenceRuleTypeYearly:
            return NSLocalizedString(@"ECRecurrenceRule.Repeats every year", @"The event repeats every year");
            
        case ECRecurrenceRuleTypeCustom:
            return [self detailStringFromCustomRecurrenceRule:rule];
    }
}

- (NSString*)detailStringFromCustomRecurrenceRule:(ECRecurrenceRule*)customRule
{
    EKRecurrenceRule* rule = customRule.rule;
    switch (rule.frequency) {
        case EKRecurrenceFrequencyDaily:
            return [NSString stringWithFormat:NSLocalizedString(@"ECRecurrenceRule.Repeats every %lu days", @"The event repeats every [interval] days"), rule.interval];
            
        case EKRecurrenceFrequencyWeekly:
            return [NSString stringWithFormat:NSLocalizedString(@"ECRecurrenceRule.Repeats every %lu weeks", @"The event repeats every [interval] weeks"), rule.interval];
            
        case EKRecurrenceFrequencyMonthly:
            return [NSString stringWithFormat:NSLocalizedString(@"ECRecurrenceRule.Repeats every %lu months", @"The event repeats every [interval] months"), rule.interval];
            
        case EKRecurrenceFrequencyYearly:
            return [NSString stringWithFormat:NSLocalizedString(@"ECRecurrenceRule.Repeats every %lu years", @"The event repeats every [interval] years"), rule.interval];
    }
}

@end
