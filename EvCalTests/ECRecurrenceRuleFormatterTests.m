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

- (void)testRecurrenceRuleDefaultFormatterCanBeCreated
{
    XCTAssertNotNil([ECRecurrenceRuleFormatter defaultFormatter]);
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

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForNoneType
{
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceType:ECRecurrenceRuleTypeNone], self.recurrenceRuleFormatter.noneRuleName);
}

- (void)testRecurrenceRuleFormatterReturnsLocalizedStringForNoneRule
{
    ECRecurrenceRule* noneRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeNone];
    
    XCTAssertEqualObjects([self.recurrenceRuleFormatter stringFromRecurrenceRule:noneRecurrenceRule], self.recurrenceRuleFormatter.noneRuleName);
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

- (void)testRecurrenceRuleFormatterHasRuleNames
{
    XCTAssertNotNil(self.recurrenceRuleFormatter.ruleNames);
}

- (void)testRecurrenceRuleFormatterRuleNamesContainsNoneRuleName
{
    XCTAssertTrue([self.recurrenceRuleFormatter.ruleNames containsObject:self.recurrenceRuleFormatter.noneRuleName]);
}

- (void)testRecurrenceRuleFormatterRuleNamesContainsDailyRuleName
{
    XCTAssertTrue([self.recurrenceRuleFormatter.ruleNames containsObject:self.recurrenceRuleFormatter.dailyRuleName]);
}

- (void)testRecurrenceRuleFormatterRuleNamesContainsWeekdaysRuleName
{
    XCTAssertTrue([self.recurrenceRuleFormatter.ruleNames containsObject:self.recurrenceRuleFormatter.weekdaysRuleName]);
}

- (void)testRecurrenceRuleFormatterRuleNamesContainsWeeklyRuleName
{
    XCTAssertTrue([self.recurrenceRuleFormatter.ruleNames containsObject:self.recurrenceRuleFormatter.weeklyRuleName]);
}

- (void)testRecurrenceRuleFormatterRuleNamesContainsMonthlyRuleName
{
    XCTAssertTrue([self.recurrenceRuleFormatter.ruleNames containsObject:self.recurrenceRuleFormatter.monthlyRuleName]);
}

- (void)testRecurrenceRuleFormatterRuleNamesContainsYearlyRuleName
{
    XCTAssertTrue([self.recurrenceRuleFormatter.ruleNames containsObject:self.recurrenceRuleFormatter.yearlyRuleName]);
}

- (void)testRecurrenceRuleFormatterRuleNamesContainsCustomRuleName
{
    XCTAssertTrue([self.recurrenceRuleFormatter.ruleNames containsObject:self.recurrenceRuleFormatter.customRuleName]);
}

- (void)testRecurrenceRuleFormatterRuleNamesContainsNoOtherStrings
{
    NSMutableArray* mutableRuleNames = [self.recurrenceRuleFormatter.ruleNames mutableCopy];
    [mutableRuleNames removeObject:self.recurrenceRuleFormatter.noneRuleName];
    [mutableRuleNames removeObject:self.recurrenceRuleFormatter.dailyRuleName];
    [mutableRuleNames removeObject:self.recurrenceRuleFormatter.weekdaysRuleName];
    [mutableRuleNames removeObject:self.recurrenceRuleFormatter.weeklyRuleName];
    [mutableRuleNames removeObject:self.recurrenceRuleFormatter.monthlyRuleName];
    [mutableRuleNames removeObject:self.recurrenceRuleFormatter.yearlyRuleName];
    [mutableRuleNames removeObject:self.recurrenceRuleFormatter.customRuleName];
    
    XCTAssertTrue(mutableRuleNames.count == 0);
}

@end
