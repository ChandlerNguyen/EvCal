//
//  ECAlarmTests.m
//  EvCal
//
//  Created by Tom on 7/10/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// Frameworks
#import <XCTest/XCTest.h>
@import EventKit;

// EvCal Classes
#import "ECAlarm.h"

@interface ECAlarmTests : XCTestCase

@property (nonatomic, strong) NSDate* testStartDate;
@end

@implementation ECAlarmTests

#pragma mark - Setup & Tear down
- (void)setUp {
    [super setUp];
    
    self.testStartDate = [NSDate date];
}

- (void)tearDown {
    
    self.testStartDate = nil;
    
    [super tearDown];
}

const static NSTimeInterval kQuarterHourTimeInterval = 15 * 60;

#pragma mark - Tests

- (void)testAlarmCanBeCreatedWithNilEKAlarm
{
    XCTAssertNotNil([[ECAlarm alloc] initWithEKAlarm:nil]);
}

- (void)testAlarmCanBeCreatedWithNonnilEKAlarm
{
    EKAlarm* ekAlarm = [EKAlarm alarmWithRelativeOffset:kQuarterHourTimeInterval];
    XCTAssertNotNil([[ECAlarm alloc] initWithEKAlarm:ekAlarm]);
}

- (void)testAlarmCreatedWithRelativeOffsetEKAlarmHasEKAlarmPropertySet
{
    EKAlarm* ekAlarm = [EKAlarm alarmWithRelativeOffset:kQuarterHourTimeInterval];
    ECAlarm* alarm = [[ECAlarm alloc] initWithEKAlarm:ekAlarm];
    XCTAssertEqualObjects(alarm.ekAlarm, ekAlarm);
}

- (void)testAlarmCreatedWithAbsoluteDateEKAlarmHasEKAlarmPropertySet
{
    EKAlarm* ekAlarm = [EKAlarm alarmWithAbsoluteDate:self.testStartDate];
    ECAlarm* alarm = [[ECAlarm alloc] initWithEKAlarm:ekAlarm];
    
    XCTAssertEqualObjects(alarm.ekAlarm, ekAlarm);
}


#pragma mark Testing Types
- (void)testAlarmCreatedWithCustomTypeThrowsInvalidArgumentException
{
    XCTAssertThrowsSpecificNamed([ECAlarm alarmWithType:ECAlarmTypeOffsetCustom], NSException, NSInvalidArgumentException);
}

- (void)testAlarmCreatedWithAbsoluteDateTypeThrowsInvalidArgumentException
{
    XCTAssertThrowsSpecificNamed([ECAlarm alarmWithType:ECAlarmTypeAbsoluteDate], NSException, NSInvalidArgumentException);
}

- (void)testAlarmCanBeCreatedWithNoneType
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeNone];
    XCTAssertNotNil(alarm);
}

- (void)testAlarmCreatedWithNoneTypeHasCorrectTypeProperty
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeNone];
    XCTAssertEqual(alarm.type, ECAlarmTypeNone);
}
- (void)testAlarmCreatedWithNoneTypeHasNilEKAlarm
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeNone];
    XCTAssertNil(alarm.ekAlarm);
}


- (void)testAlarmCenBeCreatedWithQuarterHourType
{
    XCTAssertNotNil([ECAlarm alarmWithType:ECAlarmTypeOffsetQuarterHour]);
}

- (void)testAlarmCreatedWithQuarterHourTypeHasCorrectTypeProperty
{
    ECAlarm* quarterHourAlarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetQuarterHour];
    XCTAssertEqual(quarterHourAlarm.type, ECAlarmTypeOffsetQuarterHour);
}

- (void)testAlarmCreatedWithQuarterHourEKAlarmHasCorrectTypeProperty
{
    EKAlarm* ekAlarm = [EKAlarm alarmWithRelativeOffset:kQuarterHourTimeInterval];
    ECAlarm* alarm = [[ECAlarm alloc] initWithEKAlarm:ekAlarm];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetQuarterHour);
}

- (void)testAlarmCreatedWithQuarterHourTypeHasEKAlarmWithQuarterHourRelativeOffset
{
    ECAlarm* quarterHourAlarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetQuarterHour];
    XCTAssertEqual(quarterHourAlarm.ekAlarm.relativeOffset, 15 * 60);
}
@end
