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
#import "ECAlarmFormatter.h"

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
const static NSTimeInterval kHalfHourTimeInterval = 30 * 60;
const static NSTimeInterval kOneHourTimeInterval = 60 * 60;
const static NSTimeInterval KTwoHourTimeInterval = 2 * 60 * 60;
const static NSTimeInterval kSixHourTimeInterval = 6 * 60 * 60;
const static NSTimeInterval kOneDayTimeInterval = 24 * 60 * 60;
const static NSTimeInterval kTwoDayTimeInterval = 2 * 24 * 60 * 60;



#pragma mark - Tests
#pragma mark Test alarm creation

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

- (void)testAlarmCreatedWithEKAlarmChangesTypeOnEKAlarmChange
{
    EKAlarm* ekAlarm = [EKAlarm alarmWithRelativeOffset:kQuarterHourTimeInterval];
    ECAlarm* alarm = [[ECAlarm alloc] initWithEKAlarm:ekAlarm];
    alarm.ekAlarm = [EKAlarm alarmWithRelativeOffset:kHalfHourTimeInterval];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetHalfHour);
}

- (void)testAlarmCreatedWithCustomTypeThrowsInvalidArgumentException
{
    XCTAssertThrowsSpecificNamed([ECAlarm alarmWithType:ECAlarmTypeOffsetCustom], NSException, NSInvalidArgumentException);
}

- (void)testAlarmCreatedWithAbsoluteDateTypeThrowsInvalidArgumentException
{
    XCTAssertThrowsSpecificNamed([ECAlarm alarmWithType:ECAlarmTypeAbsoluteDate], NSException, NSInvalidArgumentException);
}


#pragma mark None Type

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

- (void)testAlarmCreatedWithNoneTypeHasCorrectLocalizedName
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeNone];
    XCTAssertEqualObjects(alarm.localizedName,[ECAlarmFormatter defaultFormatter].noneAlarmLocalizedName);
}


#pragma mark Quarter Hour
- (void)testAlarmCenBeCreatedWithQuarterHourType
{
    XCTAssertNotNil([ECAlarm alarmWithType:ECAlarmTypeOffsetQuarterHour]);
}

- (void)testAlarmCreatedWithQuarterHourTypeHasCorrectTypeProperty
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetQuarterHour];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetQuarterHour);
}

- (void)testAlarmCreatedWithQuarterHourEKAlarmHasCorrectTypeProperty
{
    EKAlarm* ekAlarm = [EKAlarm alarmWithRelativeOffset:kQuarterHourTimeInterval];
    ECAlarm* alarm = [[ECAlarm alloc] initWithEKAlarm:ekAlarm];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetQuarterHour);
}

- (void)testAlarmCreatedWithQuarterHourTypeHasEKAlarmWithQuarterHourRelativeOffset
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetQuarterHour];
    XCTAssertEqual(alarm.ekAlarm.relativeOffset, 15 * 60);
}

- (void)testAlarmCreatedWithQuarterHourTypeHasCorrectLocalizedName
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetQuarterHour];
    XCTAssertEqualObjects(alarm.localizedName, [ECAlarmFormatter defaultFormatter].quarterHourAlarmLocalizedName);
}

#pragma mark Half Hour

- (void)testAlarmCanBeCreatedWithHalfHourType
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetHalfHour];
    XCTAssertNotNil(alarm);
}

- (void)testAlarmCreatedWithHalfHourTypeHasCorrectTypeProperty
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetHalfHour];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetHalfHour);
}

- (void)testAlarmCreatedWithHalfHourTypeHasEKAlarmWithHalfHourRelativeOffset
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetHalfHour];
    XCTAssertEqual(alarm.ekAlarm.relativeOffset, kHalfHourTimeInterval);
}

- (void)testAlarmCreatedWithHalfHourTypeHasCorrectLocalizedName
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetHalfHour];
    XCTAssertEqualObjects(alarm.localizedName, [ECAlarmFormatter defaultFormatter].quarterHourAlarmLocalizedName);
}


#pragma mark One Hour
- (void)testAlarmCanBeCreatedWithOneHourType
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetHour];
    XCTAssertNotNil(alarm);
}

- (void)testAlarmCreatedWithOneHourTypeHasCorrectTypeProperty
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetHour];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetHour);
}

- (void)testAlarmCreatedWithOneHourTypeHasEKAlarmWithOneHourRelativeOffset
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetHour];
    XCTAssertEqual(alarm.ekAlarm.relativeOffset, kOneHourTimeInterval);
}

- (void)testAlarmCreatedWithOneHourTypeHasCorrectLocalizedName
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetHour];
    XCTAssertEqualObjects(alarm.localizedName, [ECAlarmFormatter defaultFormatter].oneHourLocalizedName);
}

#pragma mark Two Hours
- (void)testAlarmCanBeCreatedWithTwoHoursType
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoHours];
    XCTAssertNotNil(alarm);
}

- (void)testAlarmCreatedWithTwoHoursTypeHasCorrectTypeProperty
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoHours];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetTwoHours);
}

- (void)testAlarmCreatedWithTwoHoursTypeHasEKAlarmWithTwoHourRelativeOffset
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoHours];
    XCTAssertEqual(alarm.ekAlarm.relativeOffset, KTwoHourTimeInterval);
}

- (void)testAlarmCreatedWithTwoHoursTypeHasCorrectLocalizedName
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoHours];
    XCTAssertEqualObjects(alarm.localizedName, [ECAlarmFormatter defaultFormatter].twoHoursLocalizedName);
}

#pragma mark Six Hours

- (void)testAlarmCanBeCreatedWithSixHoursType
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetSixHours];
    XCTAssertNotNil(alarm);
}

- (void)testAlarmCreatedWithSixHoursTypeHasCorrectTypeProperty
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetSixHours];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetSixHours);
}

- (void)testAlarmCreatedWithSixHoursTypeHasEKAlarmWithSixHourRelativeOffset
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetSixHours];
    XCTAssertEqual(alarm.ekAlarm.relativeOffset, kSixHourTimeInterval);
}

- (void)testAlarmCreatedWithSixHoursTypeHasCorrectLocalizedName
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetSixHours];
    XCTAssertEqualObjects(alarm.localizedName, [ECAlarmFormatter defaultFormatter].sixHoursLocalizedName);
}

#pragma mark One Day

- (void)testAlarmCanBeCreatedWithOneDayType
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetOneDay];
    XCTAssertNotNil(alarm);
}

- (void)testAlarmCreatedWithOneDayTypeHasCorrectTypePropertySet
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetOneDay];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetOneDay);
}

- (void)testALarmCreatedWithOneDayTypeHasEKAlarmWithOneDayRelativeOffset
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetOneDay];
    XCTAssertEqual(alarm.ekAlarm.relativeOffset, kOneDayTimeInterval);
}

- (void)testAlarmCreatedWithOneDayTypeHasCorrectLocalizedName
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetOneDay];
    XCTAssertEqualObjects(alarm.localizedName, [ECAlarmFormatter defaultFormatter].oneDayLocalizedName);
}

#pragma mark Two Days

- (void)testAlarmCanBeCreatedWithTwoDaysType
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoDays];
    XCTAssertNotNil(alarm);
}

- (void)testAlarmCreatedWithTwoDaysTypeHasCorrectyTypeProperty
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoDays];
    XCTAssertEqual(alarm.type, ECAlarmTypeOffsetTwoDays);
}

- (void)testAlarmCreatedWithTwoDaysTypeHasEKAlarmWithTwoDaysRelativeOffset
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoDays];
    XCTAssertEqual(alarm.ekAlarm.relativeOffset, kTwoDayTimeInterval);
}

- (void)testAlarmCreatedWithTwoDaysTypeHasCorrectLocalizedName
{
    ECAlarm* alarm = [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoDays];
    XCTAssertEqualObjects(alarm.localizedName, [ECAlarmFormatter defaultFormatter].localizedNames);
}


#pragma mark Absolute Date

- (void)testAlarmCanBeCreatedWithAbsoluteDate
{
    ECAlarm* alarm = [ECAlarm alarmWithDate:self.testStartDate];
    XCTAssertNotNil(alarm);
}

- (void)testAlarmCreatedWithAbsoluteDateHasCorrectTypeProperty
{
    ECAlarm* alarm = [ECAlarm alarmWithDate:self.testStartDate];
    XCTAssertEqual(alarm.type, ECAlarmTypeAbsoluteDate);
}

- (void)testAlarmCreatedWithAbsoluteDateHasEKAlarmWithSameAbsoluteDate
{
    ECAlarm* alarm = [ECAlarm alarmWithDate:self.testStartDate];
    XCTAssertEqualObjects(alarm.ekAlarm.absoluteDate, self.testStartDate);
}


@end
