//
//  ECDateViewTests.m
//  EvCal
//
//  Created by Tom on 6/25/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// Frameworks
@import EventKit;
#import <XCTest/XCTest.h>

// EvCal Classes
#import "ECDateView.h"

@interface ECDateViewTests : XCTestCase

@property (nonatomic, strong) NSDate* testStartDate;

@end

@implementation ECDateViewTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
    self.testStartDate = [NSDate date];
}

- (void)tearDown {
    
    self.testStartDate = nil;
    
    [super tearDown];
}

#pragma mark - Tests
#pragma mark Creating date views
- (void)testDateViewCanBeCreated
{
    ECDateView* dateView = [[ECDateView alloc] initWithDate:self.testStartDate];
    
    XCTAssertNotNil(dateView);
}

- (void)testDateViewHasCorrectDate
{
    ECDateView* dateView = [[ECDateView alloc] initWithDate:self.testStartDate];
    
    XCTAssertTrue([[NSCalendar currentCalendar] isDate:dateView.date inSameDayAsDate:self.testStartDate]);
}

- (void)testDateViewIsNotSelectedByDefault
{
    ECDateView* dateView = [[ECDateView alloc] initWithDate:self.testStartDate];
    
    XCTAssertFalse(dateView.isSelectedDate);
}

- (void)testDateViewCalendarsNilByDefault
{
    ECDateView* dateView = [[ECDateView alloc] initWithDate:self.testStartDate];
    
    XCTAssertNil(dateView.calendars);
}

#pragma mark Today's date
- (void)testDateViewIsTodaysDateReturnsNoIfNotInTodaysDate
{
    NSDate* twoDaysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-2 toDate:self.testStartDate options:0];
    ECDateView* dateView = [[ECDateView alloc] initWithDate:twoDaysAgo];
    
    XCTAssertFalse(dateView.isTodaysDate);
}

- (void)testDateViewIsTodaysDateReturnsCorrectAnswer
{
    ECDateView* dateView = [[ECDateView alloc] initWithDate:self.testStartDate];
   
    // This test could fail if run close to the end of the day
    XCTAssertEqual(dateView.isTodaysDate, [[NSCalendar currentCalendar] isDateInToday:self.testStartDate]);
}

#pragma mark Selecting date
- (void)testDateViewSelectedDateCanBeChangedToYes
{
    ECDateView* dateView = [[ECDateView alloc] initWithDate:self.testStartDate];
    
    [dateView setSelectedDate:YES animated:NO];
    
    XCTAssertTrue(dateView.isSelectedDate);
}

- (void)testDateViewSelectedDateCanBeChangedToNo
{
    ECDateView* dateView = [[ECDateView alloc] initWithDate:self.testStartDate];
    
    [dateView setSelectedDate:YES animated:NO];
    [dateView setSelectedDate:NO animated:NO];
    
    XCTAssertFalse(dateView.isSelectedDate);
}

#pragma mark Changing calendars

- (void)testDateViewCalendarsCanBeSet
{
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    NSArray* eventCalendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
    
    ECDateView* dateView = [[ECDateView alloc] initWithDate:self.testStartDate];
    dateView.calendars = eventCalendars;
    
    XCTAssertEqualObjects(eventCalendars, dateView.calendars);
}

@end
