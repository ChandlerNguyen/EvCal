//
//  ECAlarmFormatterTests.m
//  EvCal
//
//  Created by Tom on 7/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ECAlarmFormatter.h"

@interface ECAlarmFormatterTests : XCTestCase

@property (nonatomic, strong) ECAlarmFormatter* alarmFormatter;

@end

@implementation ECAlarmFormatterTests

#pragma mark - Setup & Tear down

- (void)setUp {
    [super setUp];
    
    self.alarmFormatter = [[ECAlarmFormatter alloc] init];
}

- (void)tearDown {
    self.alarmFormatter = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testAlarmFormatterCanBeCreated
{
    XCTAssertNotNil(self.alarmFormatter);
}

- (void)testAlarmFormatterHasNoneAlarmLocalizedNameProperty
{
    XCTAssertNotNil(self.alarmFormatter.noneAlarmLocalizedName);
}

- (void)testAlarmFormatterHasQuarterHourAlarmLocalizedNameProperty
{
    XCTAssertNotNil(self.alarmFormatter.quarterHourAlarmLocalizedName);
}

- (void)testAlarmFormatterHasHalfHourAlarmLocalizedNameProperty
{
    XCTAssertNotNil(self.alarmFormatter.halfHourLocalizedName);
}

- (void)testAlarmFormatterHasHourAlarmLocalizedNameProperty
{
    XCTAssertNotNil(self.alarmFormatter.oneHourLocalizedName);
}

- (void)testAlarmFormatterHasTwoHoursLocalizedNameProperty
{
    XCTAssertNotNil(self.alarmFormatter.twoHoursLocalizedName);
}

- (void)testAlarmFormatterHasSixHoursLocalizedNameProperty
{
    XCTAssertNotNil(self.alarmFormatter.sixHoursLocalizedName);
}

- (void)testAlarmFormatterHasOneDayLocalizedNameProperty
{
    XCTAssertNotNil(self.alarmFormatter.oneDayLocalizedName);
}

- (void)testAlarmFormatterHasTwoDaysLocalizedNameProperty
{
    XCTAssertNotNil(self.alarmFormatter.twoDaysLocalizedName);
}

- (void)testAlarmFormatterHasLocalizedNamesProperty
{
    XCTAssertNotNil(self.alarmFormatter.localizedNames);
}

- (void)testAlarmFormatterLocalizedNamesContainsNoneLocalizedName
{
    XCTAssertTrue([self.alarmFormatter.localizedNames containsObject:self.alarmFormatter.noneAlarmLocalizedName]);
}

- (void)testAlarmFormatterLocalizedNamesContainsQuarterHourLocalizedName
{
    XCTAssertTrue([self.alarmFormatter.localizedNames containsObject:self.alarmFormatter.quarterHourAlarmLocalizedName]);
}

- (void)testAlarmFormatterLocalizedNamesContainsHalfHourLocalizedName
{
    XCTAssertTrue([self.alarmFormatter.localizedNames containsObject:self.alarmFormatter.halfHourLocalizedName]);
}

- (void)testAlarmFormatterLocalizedNamesContainsOneHourLocalizedName
{
    XCTAssertTrue([self.alarmFormatter.localizedNames containsObject:self.alarmFormatter.oneHourLocalizedName]);
}

- (void)testAlarmFormatterLocalizedNamesContainsTwoHoursLocalizedName
{
    XCTAssertTrue([self.alarmFormatter.localizedNames containsObject:self.alarmFormatter.twoHoursLocalizedName]);
}

- (void)testAlarmFormatterLocalizedNamesContainsSixHoursLocalizedName
{
    XCTAssertTrue([self.alarmFormatter.localizedNames containsObject:self.alarmFormatter.sixHoursLocalizedName]);
}

@end
