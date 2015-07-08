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

- (void)testRecurrenceRuleLocalizeStringsPropertyDefaultsToYES
{
    XCTAssertTrue(self.recurrenceRuleFormatter.localizeStrings);
}

- (void)testRecurrenceRuleDefaultFormatterCanBeCreated
{
    XCTAssertNotNil([ECRecurrenceRuleFormatter defaultFormatter]);
}

- (void)testRecurrenceRuleDefaultFormatterLocalizeStringsPropertyDefaultsToYES
{
    XCTAssertTrue([ECRecurrenceRuleFormatter defaultFormatter].localizeStrings);
}

- (void)testRecurrenceRuleFormatterCanBeInitializedWithLocalizeStringsNO
{
    ECRecurrenceRuleFormatter* nonLocalizedFormatter = [[ECRecurrenceRuleFormatter alloc] initUsingLocalization:NO];
    
    XCTAssertFalse(nonLocalizedFormatter.localizeStrings);
}

- (void)testRecurrenceRuleFormatterDailyRuleNameIsNotNil
{
    XCTAssertNotNil(self.recurrenceRuleFormatter.dailyRuleName);
}

- (void)testRecurrenceRuleFormatterWeekdaysRuleNameIsNotNil
{
    XCTAssertNotNil(self.recurrenceRuleFormatter.weekdaysRuleName);
}

- (void)testRecurrenceRuleFormatterWeeklyRuleNameIsNotNil
{
    XCTAssertNotNil(self.recurrenceRuleFormatter.weeklyRuleName);
}

- (void)testRecurrenceRuleFormatterMonthlyRuleNameIsNotNil
{
    XCTAssertNotNil(self.recurrenceRuleFormatter.monthlyRuleName);
}

- (void)testRecurrenceRuleFormatterYearlyRuleNameIsNotNil
{
    XCTAssertNotNil(self.recurrenceRuleFormatter.yearlyRuleName);
}

- (void)testRecurrenceRuleFormatterCustomRuleNameIsNotNil
{
    XCTAssertNotNil(self.recurrenceRuleFormatter.customRuleName);
}

#pragma mark Creating strings

- (void)testRecurrenceRuleFormatterRaisesInvalidArgumentExceptionForUnrecognizedRecurrenceType
{
    XCTAssertThrowsSpecificNamed([self.recurrenceRuleFormatter stringFromRecurrenceType:(ECRecurrenceRuleType)-1], NSException, NSInvalidArgumentException);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForDailyType
{
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceType:ECRecurrenceRuleTypeDaily], self.recurrenceRuleFormatter.dailyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForDailyRule
{
    ECRecurrenceRule* dailyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
    
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceRule:dailyRecurrenceRule], self.recurrenceRuleFormatter.dailyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForWeekdaysType
{
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceType:ECRecurrenceRuleTypeWeekdays], self.recurrenceRuleFormatter.weekdaysRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForWeekdaysRule
{
    ECRecurrenceRule* weekdaysRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
    
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceRule:weekdaysRecurrenceRule], self.recurrenceRuleFormatter.weekdaysRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForWeeklyType
{
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceType:ECRecurrenceRuleTypeWeekly], self.recurrenceRuleFormatter.weeklyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForWeeklyRule
{
    ECRecurrenceRule* weeklyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
    
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceRule:weeklyRecurrenceRule], self.recurrenceRuleFormatter.weeklyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForMonthlyType
{
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceType:ECRecurrenceRuleTypeMonthly], self.recurrenceRuleFormatter.monthlyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForMonthlyRule
{
    ECRecurrenceRule* monthlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
    
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceRule:monthlyRecurrenceRule], self.recurrenceRuleFormatter.monthlyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForYearlyType
{
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceType:ECRecurrenceRuleTypeYearly], self.recurrenceRuleFormatter.yearlyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForYearlyRule
{
    ECRecurrenceRule* yearlyRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
    
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceRule:yearlyRecurrenceRule], self.recurrenceRuleFormatter.yearlyRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForCustomType
{
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceType:ECRecurrenceRuleTypeCustom], self.recurrenceRuleFormatter.customRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForCustomRule
{
    ECRecurrenceRule* customRecurrenceRule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:EKRecurrenceFrequencyDaily interval:2];
    
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceRule:customRecurrenceRule], self.recurrenceRuleFormatter.customRuleName);
}

@end
