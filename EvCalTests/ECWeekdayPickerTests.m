//
//  ECWeekdayPickerTests.m
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
#import <XCTest/XCTest.h>
@import EventKit;

// Helpers
#import "NSArray+ECTesting.h"

// EvCal Classes
#import "ECWeekdayPicker.h"

@interface ECWeekdayPickerTests : XCTestCase <ECWeekdayPickerDelegate, ECWeekdayPickerDataSource>

@property (nonatomic) BOOL didSelectDateCalled;
@property (nonatomic) BOOL calendarsRequested;

@property (nonatomic, strong) NSDate* testStartDate;
@property (nonatomic, strong) ECWeekdayPicker* picker;


@end

@implementation ECWeekdayPickerTests

#pragma mark - Setup and Teardown

- (void)setUp {
    [super setUp];

    self.didSelectDateCalled = NO;
    self.calendarsRequested = NO;

    self.testStartDate = [NSDate date];
    self.picker = [[ECWeekdayPicker alloc] initWithDate:self.testStartDate];
    self.picker.pickerDataSource = self;
    self.picker.pickerDelegate = self;
}

- (void)tearDown {
    [super tearDown];
    
    self.picker = nil;
}

#pragma mark - Tests

// This is a helper function for testing weekday picker's correctness
- (void)assertWeekdays:(NSArray*)weekdays containCorrectDaysForDate:(NSDate*)date message:(NSString*)message
{
    XCTAssertEqual(weekdays.count, 7, @"%@", message);
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSUInteger indexOfDate = [weekdays indexOfDateInSameDayAsDate:date];
    
    XCTAssertFalse(indexOfDate == NSNotFound, @"%@", message);
    
    for (NSUInteger i = 0; i < weekdays.count; i++) {
        NSDate* expectedDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:(-indexOfDate + i) toDate:date options:0];
        
        XCTAssertTrue([calendar isDate:weekdays[i] inSameDayAsDate:expectedDate], @"%@", message);
    }
}

#pragma mark Data source and delegate

- (void)weekdayPicker:(ECWeekdayPicker *)picker didSelectDate:(NSDate *)date
{
    self.didSelectDateCalled = YES;
}

- (NSArray*)calendarsForDate:(NSDate *)date
{
    self.calendarsRequested = YES;
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    
    return [eventStore calendarsForEntityType:EKEntityTypeEvent];
}

#pragma mark Creating and Initialization

- (void)testPickerCanBeCreated
{
    XCTAssertNotNil(self.picker);
}

- (void)testPickerLoadsOneWeekOfDates
{
    [self assertWeekdays:self.picker.weekdays containCorrectDaysForDate:self.testStartDate message:@"ECWeekdayPicker should load weekdays when initialized with a date"];
}

- (void)testPickerSelectedDateSet
{
    XCTAssert([[NSCalendar currentCalendar] isDate:self.picker.selectedDate inSameDayAsDate:self.testStartDate], @"ECWeekdayPicker did not set its selected date upon initialization");
}

- (void)testPickerDataSourceSetCorrectly
{
    XCTAssertEqualObjects(self.picker.pickerDataSource, self);
}

- (void)testPickerDelegateSetCorrectly
{
    XCTAssertEqualObjects(self.picker.pickerDelegate, self);
}

#pragma mark Selecting Picker Date

- (void)testPickerCanChangeSelectedDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* lastWeekDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:self.testStartDate options:0];
    
    [self.picker setSelectedDate:lastWeekDate];
    
    XCTAssertTrue([calendar isDate:self.picker.selectedDate inSameDayAsDate:lastWeekDate], @"ECWeekdayPicker's selectedDate should be changed");
}

- (void)testPickerDoesNotCallDataSourceIfWeekdaysDoNotChange
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSInteger weekdayIndex = [calendar components:(NSCalendarUnitWeekday) fromDate:self.testStartDate].weekday;
    
    if (weekdayIndex == self.picker.weekdays.count) {
        weekdayIndex -= 2;
    }
    
    NSDate* dateInSameWeek = self.picker.weekdays[weekdayIndex];
    [self.picker setSelectedDate:dateInSameWeek];
    
    XCTAssertFalse(self.calendarsRequested);
}

- (void)testPickerCallsDataSourceWhenWeekdaysChange
{
    NSDate* lastWeekDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:self.testStartDate options:0];
    
    [self.picker setSelectedDate:lastWeekDate];
    
    XCTAssertTrue(self.calendarsRequested);
}

- (void)testPickerChangesWeekdaysWhenSelectedDateChanges
{
    NSDate* lastWeekDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:self.testStartDate options:0];
    
    [self.picker setSelectedDate:lastWeekDate];
    
    [self assertWeekdays:self.picker.weekdays containCorrectDaysForDate:lastWeekDate message:@"ECWeekdayPicker should update its weekdays when the selected date is changed"];
}

- (void)testPickerCallsDelegateWhenSelectedDateChanges
{
    [self.picker setSelectedDate:[NSDate date]];
    
    XCTAssertTrue(self.didSelectDateCalled, @"ECWeekdayPicker should call its delegate when selected date is changed");
}

#pragma mark Refreshing Picker

- (void)testRefreshingWeekdaysCallsDataSource
{
    [self.picker refreshWeekdays];
    
    XCTAssertTrue(self.calendarsRequested);
}

- (void)testRefreshingWeekdaysDoesNotChangeSelectedDate
{
    [self.picker refreshWeekdays];
    
    XCTAssertTrue([[NSCalendar currentCalendar] isDate:self.testStartDate inSameDayAsDate:self.picker.selectedDate]);
}

- (void)testRefreshingWeekdayWithDateCallsDataSource
{
    [self.picker refreshWeekdayWithDate:self.testStartDate];
    
    XCTAssertTrue(self.calendarsRequested);
}

- (void)testRefreshingWeekdayWithDateDoesNotChangeSelectedDate
{
    [self.picker refreshWeekdayWithDate:self.testStartDate];
    
    XCTAssertTrue([[NSCalendar currentCalendar] isDate:self.testStartDate inSameDayAsDate:self.picker.selectedDate]);
}

@end
