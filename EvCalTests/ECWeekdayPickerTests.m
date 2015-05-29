//
//  ECWeekdayPickerTests.m
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
#import <XCTest/XCTest.h>

// Helpers
#import "NSArray+ECTesting.h"

// EvCal Classes
#import "ECWeekdayPicker.h"

@interface ECWeekdayPickerTests : XCTestCase <ECWeekdayPickerDelegate>

@property (nonatomic) BOOL delegateCalled;
@property (nonatomic, strong) NSDate* testStartDate;
@property (nonatomic, strong) ECWeekdayPicker* picker;

@end

@implementation ECWeekdayPickerTests

#pragma mark - Setup and Teardown

- (void)setUp {
    [super setUp];

    self.delegateCalled = NO;
    self.testStartDate = [NSDate date];
    self.picker = [[ECWeekdayPicker alloc] initWithDate:self.testStartDate];
}

- (void)tearDown {
    [super tearDown];
    
    self.picker = nil;
}

#pragma mark - Tests

// This is a helper function for testing weekday picker's correctness
- (void)assertWeekdays:(NSArray*)weekdays containCorrectDaysForDate:(NSDate*)date
{
    XCTAssertEqual(weekdays.count, 7);
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSUInteger indexOfDate = [weekdays indexOfDateInSameDayAsDate:date];
    
    XCTAssertFalse(indexOfDate == NSNotFound);
    
    for (NSUInteger i = 0; i < weekdays.count; i++) {
        NSDate* expectedDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:(-indexOfDate + i) toDate:date options:0];
        
        XCTAssertTrue([calendar isDate:weekdays[i] inSameDayAsDate:expectedDate]);
    }
}

#pragma mark Creating and Initialization

- (void)testPickerLoadsOneWeekOfDates
{
    [self assertWeekdays:self.picker.weekdays containCorrectDaysForDate:self.testStartDate];
}

#pragma mark Scrolling and Delegation

- (void)testScrolledPickerWeekdaysContainScrolledToDate
{
    NSDate* scrollToDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                    value:7
                                                                   toDate:self.testStartDate options:0];

    [self.picker scrollToWeekContainingDate:scrollToDate];
    
    [self assertWeekdays:self.picker.weekdays containCorrectDaysForDate:scrollToDate];
}

- (void)weekdayPicker:(ECWeekdayPicker *)picker didScrollFrom:(NSArray *)fromWeek to:(NSArray *)toWeek
{
    self.delegateCalled = YES;
}

- (void)testScrolledPickerCallsDelegateMethod
{
    self.picker.pickerDelegate = self;
    
    [self.picker scrollToWeekContainingDate:[NSDate date]];
    
    XCTAssertTrue(self.delegateCalled);
}
@end
