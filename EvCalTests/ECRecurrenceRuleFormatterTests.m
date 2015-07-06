//
//  ECRecurrenceRuleFormatterTests.m
//  EvCal
//
//  Created by Tom on 7/6/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// Frameworks
@import EventKit;
#import <XCTest/XCTest.h>

// EvCal Classes
#import "ECRecurrenceRuleFormatter.h"

@interface ECRecurrenceRuleFormatterTests : XCTestCase

@property (nonatomic, strong) ECRecurrenceRuleFormatter* recurrenceRuleFormatter;

@end

@implementation ECRecurrenceRuleFormatterTests

#pragma mark - Setup & tear down

- (void)setUp {
    [super setUp];

    self.recurrenceRuleFormatter = [[ECRecurrenceRuleFormatter alloc] init];
}

- (void)tearDown {
    
    self.recurrenceRuleFormatter = nil;
    
    [super tearDown];
}


#pragma mark - Tests

- (void)testRecurrenceRuleFormatterCanBeCreated
{
    XCTAssertNotNil(self.recurrenceRuleFormatter);
}

- (void)testRecurrenceRuleFormatterReturnsNilForUnrecognizedType
{
    EKRecurrenceRule* recurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:(ECRecurrenceRuleType)-1];
    
    XCTAssertNil(recurrenceRule);
}

#pragma mark Creating daily rule
- (void)testRecurrenceRuleCreatesRecurrenceRuleForDailyRecurrenceType
{
    EKRecurrenceRule* dailyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertNotNil(dailyRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForDailyRecurrenceTypeWithDailyFrequency
{
    EKRecurrenceRule* dailyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertEqual(dailyRecurrenceRule.frequency, EKRecurrenceFrequencyDaily);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForDailyRecurrenceTypeWithIntervalOfOne
{
    EKRecurrenceRule* dailyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertEqual(dailyRecurrenceRule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForDailyRecurrenceTypeWithNilRecurrenceEnd
{
    EKRecurrenceRule* dailyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertNil(dailyRecurrenceRule.recurrenceEnd);
}

#pragma mark Creating weekday rule
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceType
{
    EKRecurrenceRule* weekdayRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertNotNil(weekdayRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceTypeWithWeeklyFrequency
{
    EKRecurrenceRule* weekdayRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertEqual(weekdayRecurrenceRule.frequency, EKRecurrenceFrequencyWeekly);
}
    
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceTypeWithIntervalOfOne
{
    EKRecurrenceRule* weekdayRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertEqual(weekdayRecurrenceRule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceTypeWithWeekdays
{
    EKRecurrenceRule* weekdayRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    NSArray* weekdays = @[[EKRecurrenceDayOfWeek dayOfWeek:EKMonday],
                          [EKRecurrenceDayOfWeek dayOfWeek:EKTuesday],
                          [EKRecurrenceDayOfWeek dayOfWeek:EKWednesday],
                          [EKRecurrenceDayOfWeek dayOfWeek:EKThursday],
                          [EKRecurrenceDayOfWeek dayOfWeek:EKFriday]];
    
    XCTAssertEqualObjects(weekdayRecurrenceRule.daysOfTheWeek, weekdays);
}


- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeekdayRecurrenceTypeWithNilRecurrenceEnd
{
    EKRecurrenceRule* weekdayRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];

    XCTAssertNil(weekdayRecurrenceRule.recurrenceEnd);
}

#pragma mark Creating weekly rule
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeeklyRecurrenceType
{
    EKRecurrenceRule* weeklyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertNotNil(weeklyRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeeklyRecurrenceTypeWithWeeklyFrequency
{
    EKRecurrenceRule* weeklyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertEqual(weeklyRecurrenceRule.frequency, EKRecurrenceFrequencyWeekly);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeeklyRecurrenceTypeWithIntervalOfOne
{
    EKRecurrenceRule* weeklyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertEqual(weeklyRecurrenceRule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForWeeklyRecurrenceTypeWithNilRecurrenceEnd
{
    EKRecurrenceRule* weeklyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertNil(weeklyRecurrenceRule.recurrenceEnd);
}

#pragma mark Creating monthly rule
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForMonthlyRecurrenceType
{
    EKRecurrenceRule* monthlyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertNotNil(monthlyRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForMonthlyRecurrenceTypeWithMonthlyFrequency
{
    EKRecurrenceRule* monthlyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];

    XCTAssertEqual(monthlyRecurrenceRule.frequency, EKRecurrenceFrequencyMonthly);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForMonthlyRecurrenceTypeWithIntervalOfOne
{
    EKRecurrenceRule* monthlyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertEqual(monthlyRecurrenceRule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForMonthlyRecurrenceTypeWithNilRecurrenceEnd
{
    EKRecurrenceRule* monthlyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertNil(monthlyRecurrenceRule.recurrenceEnd);
}

#pragma mark Creating yearly rule
- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForYearlyRecurrenceType
{
    EKRecurrenceRule* yearlyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertNotNil(yearlyRecurrenceRule);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForYearlyRecurrenceTypeWithFrequencyOfYearly
{
    EKRecurrenceRule* yearlyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertEqual(yearlyRecurrenceRule.frequency, EKRecurrenceFrequencyYearly);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForYearlyRecurrenceTypeWithIntervalOfOne
{
    EKRecurrenceRule* yearlyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertEqual(yearlyRecurrenceRule.interval, 1);
}

- (void)testRecurrenceRuleFormatterCreatesRecurrenceRuleForYearlyRecurrenceTypeWithNilRecurrenceEnd
{
    EKRecurrenceRule* yearlyRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertNil(yearlyRecurrenceRule.recurrenceEnd);
}

- (void)testRecurrenceRuleFormatterReturnsNilForCustomRecurrenceType
{
    EKRecurrenceRule* customRecurrenceRule = [self.recurrenceRuleFormatter recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeCustom];
    
    XCTAssertNil(customRecurrenceRule);
}


@end
