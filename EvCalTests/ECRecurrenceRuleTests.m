//
//  ECRecurrenceRuleTests.m
//  EvCal
//
//  Created by Tom on 7/7/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ECRecurrenceRule.h"
#import "ECRecurrenceRuleFormatter.h"

@interface ECRecurrenceRuleTests : XCTestCase

@end

@implementation ECRecurrenceRuleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Tests

#pragma mark Properties

- (void)testRecurrenceRuleHasCorrectEKRecurrenceRule
{
    EKRecurrenceRule* rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:nil];
    ECRecurrenceRule* ecRule = [[ECRecurrenceRule alloc] initWithRecurrenceRule:rule];
    
    XCTAssertEqualObjects(ecRule.rule, rule);
}

- (void)testRecurrenceRuleCanBeCreatedWithNilEKRule
{
    ECRecurrenceRule* ecRule = [[ECRecurrenceRule alloc] initWithRecurrenceRule:nil];
    
    XCTAssertNil(ecRule.rule);
}

- (void)testRecurrenceRuleHasCorrectlyDeterminesRuleType
{
    EKRecurrenceRule* rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:nil];
    ECRecurrenceRule* ecRule = [[ECRecurrenceRule alloc] initWithRecurrenceRule:rule];
    
    XCTAssertEqual(ecRule.type, ECRecurrenceRuleTypeDaily);
}

- (void)testRecurrenceRuleReturnsLocalizedString
{
    ECRecurrenceRule* rule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertNotNil(rule.localizedName);
}

- (void)testRecurrenceRuleReturnsCorrectName
{
    ECRecurrenceRule* rule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertEqualObjects(rule.localizedName, [ECRecurrenceRuleFormatter defaultFormatter].dailyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsNilForUnrecognizedType
{
    ECRecurrenceRule* recurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:(ECRecurrenceRuleType)-1];
    
    XCTAssertNil(recurrenceRule);
}

#pragma mark Creating daily rule

- (void)testRecurrenceRuleCreatesRecurrenceRuleForNoneRecurrenceType
{
    ECRecurrenceRule* noneRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeNone];
    
    XCTAssertNotNil(noneRecurrenceRule);
}

- (void)testRecurrenceRuleCreatesNilECRuleForNoneRecurrenceType
{
    ECRecurrenceRule* noneRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeNone];
    
    XCTAssertNotNil(noneRecurrenceRule);
}

- (void)testRecurrenceRuleCorrectlySetsNoneType
{
    ECRecurrenceRule* noneRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeNone];
    
    XCTAssertEqual(noneRecurrenceRule.type, ECRecurrenceRuleTypeNone);
}

- (void)testRecurrenceRuleCreatesRecurrenceRuleForDailyRecurrenceType
{
    ECRecurrenceRule* dailyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertNotNil(dailyRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForDailyRecurrenceTypeWithDailyFrequency
{
    ECRecurrenceRule* dailyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertEqual(dailyRecurrenceRule.rule.frequency, EKRecurrenceFrequencyDaily);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForDailyRecurrenceTypeWithIntervalOfOne
{
    ECRecurrenceRule* dailyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertEqual(dailyRecurrenceRule.rule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForDailyRecurrenceTypeWithNilRecurrenceEnd
{
    ECRecurrenceRule* dailyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertNil(dailyRecurrenceRule.rule.recurrenceEnd);
}

#pragma mark Creating weekday rule
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceType
{
    ECRecurrenceRule* weekdayRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertNotNil(weekdayRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceTypeWithWeeklyFrequency
{
    ECRecurrenceRule* weekdayRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertEqual(weekdayRecurrenceRule.rule.frequency, EKRecurrenceFrequencyWeekly);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceTypeWithIntervalOfOne
{
    ECRecurrenceRule* weekdayRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertEqual(weekdayRecurrenceRule.rule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceTypeWithWeekdays
{
    ECRecurrenceRule* weekdayRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    NSArray* weekdays = @[[EKRecurrenceDayOfWeek dayOfWeek:EKMonday],
                          [EKRecurrenceDayOfWeek dayOfWeek:EKTuesday],
                          [EKRecurrenceDayOfWeek dayOfWeek:EKWednesday],
                          [EKRecurrenceDayOfWeek dayOfWeek:EKThursday],
                          [EKRecurrenceDayOfWeek dayOfWeek:EKFriday]];
    
    XCTAssertEqualObjects(weekdayRecurrenceRule.rule.daysOfTheWeek, weekdays);
}


- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceTypeWithNilRecurrenceEnd
{
    ECRecurrenceRule* weekdayRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertNil(weekdayRecurrenceRule.rule.recurrenceEnd);
}

#pragma mark Creating weekly rule
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeeklyRecurrenceType
{
    ECRecurrenceRule* weeklyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertNotNil(weeklyRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeeklyRecurrenceTypeWithWeeklyFrequency
{
    ECRecurrenceRule* weeklyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertEqual(weeklyRecurrenceRule.rule.frequency, EKRecurrenceFrequencyWeekly);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeeklyRecurrenceTypeWithIntervalOfOne
{
    ECRecurrenceRule* weeklyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertEqual(weeklyRecurrenceRule.rule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeeklyRecurrenceTypeWithNilRecurrenceEnd
{
    ECRecurrenceRule* weeklyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertNil(weeklyRecurrenceRule.rule.recurrenceEnd);
}

#pragma mark Creating monthly rule
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForMonthlyRecurrenceType
{
    ECRecurrenceRule* monthlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertNotNil(monthlyRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForMonthlyRecurrenceTypeWithMonthlyFrequency
{
    ECRecurrenceRule* monthlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertEqual(monthlyRecurrenceRule.rule.frequency, EKRecurrenceFrequencyMonthly);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForMonthlyRecurrenceTypeWithIntervalOfOne
{
    ECRecurrenceRule* monthlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertEqual(monthlyRecurrenceRule.rule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForMonthlyRecurrenceTypeWithNilRecurrenceEnd
{
    ECRecurrenceRule* monthlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertNil(monthlyRecurrenceRule.rule.recurrenceEnd);
}

#pragma mark Creating yearly rule
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForYearlyRecurrenceType
{
    ECRecurrenceRule* yearlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertNotNil(yearlyRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForYearlyRecurrenceTypeWithFrequencyOfYearly
{
    ECRecurrenceRule* yearlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertEqual(yearlyRecurrenceRule.rule.frequency, EKRecurrenceFrequencyYearly);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForYearlyRecurrenceTypeWithIntervalOfOne
{
    ECRecurrenceRule* yearlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertEqual(yearlyRecurrenceRule.rule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForYearlyRecurrenceTypeWithNilRecurrenceEnd
{
    ECRecurrenceRule* yearlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertNil(yearlyRecurrenceRule.rule.recurrenceEnd);
}

#pragma mark Creating custom rules

- (void)testRecurrenceRuleFormatterReturnsNilForCustomRecurrenceType
{
    ECRecurrenceRule* customRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeCustom];
    
    XCTAssertNil(customRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesCustomRule
{
    ECRecurrenceRule* customRecurrenceRule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:EKRecurrenceFrequencyDaily interval:2];
    
    XCTAssertNotNil(customRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesCustomRuleWithCorrectFrequency
{
    EKRecurrenceFrequency testFrequency = EKRecurrenceFrequencyDaily;
    ECRecurrenceRule* customRecurrenceRule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:testFrequency interval:2];
    
    XCTAssertEqual(customRecurrenceRule.rule.frequency, testFrequency);
}

- (void)testRecurrenceRuleFormatterCreatesCustomRuleWithCorrectInterval
{
    NSInteger testInterval = 2;
    ECRecurrenceRule* customRecurrenceRule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:EKRecurrenceFrequencyDaily interval:testInterval];
    
    XCTAssertEqual(customRecurrenceRule.rule.interval, testInterval);
}

- (void)testRecurrenceRuleFormatterCreatesCustomRuleWithNilRecurrenceEnd
{
    ECRecurrenceRule* customRecurrenceRule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:EKRecurrenceFrequencyDaily interval:2];
    
    XCTAssertNil(customRecurrenceRule.rule.recurrenceEnd);
}

#pragma mark Determining recurrence type
- (void)testRecurrenceRuleFormatterReturnsDailyTypeForDailyRecurrenceRule
{
    ECRecurrenceRule* dailyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertEqual(dailyRecurrenceRule.type, ECRecurrenceRuleTypeDaily);
}

- (void)testRecurrenceRuleFormatterReturnsWeekdaysTypeForWeekdaysRecurrenceRule
{
    ECRecurrenceRule* weekdayRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertEqual(weekdayRecurrenceRule.type, ECRecurrenceRuleTypeWeekdays);
}

- (void)testRecurrenceRuleFormatterReturnsWeeklyTypeForWeeklyRecurrenceRule
{
    ECRecurrenceRule* weeklyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertEqual(weeklyRecurrenceRule.type, ECRecurrenceRuleTypeWeekly);
}

- (void)testRecurrenceRuleFormatterReturnsMonthlyTypeForMonthlyRecurrenceRule
{
    ECRecurrenceRule* monthlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertEqual(monthlyRecurrenceRule.type, ECRecurrenceRuleTypeMonthly);
}

- (void)testRecurrenceRuleFormatterReturnsYearlyTypeForYearlyRecurrenceRule
{
    ECRecurrenceRule* yearlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertEqual(yearlyRecurrenceRule.type, ECRecurrenceRuleTypeYearly);
}

- (void)testRecurrenceRuleFormatterReturnsCustomTypeForCustomRecurrenceRule
{
    ECRecurrenceRule* customRecurrenceRule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:EKRecurrenceFrequencyDaily interval:2];
    
    XCTAssertEqual(customRecurrenceRule.type, ECRecurrenceRuleTypeCustom);
}

@end
