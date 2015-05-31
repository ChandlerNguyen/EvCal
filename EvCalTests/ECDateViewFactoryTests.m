//
//  ECDateViewFactoryTests.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
#import <XCTest/XCTest.h>

// EvCal Classes
#import "ECDateView.h"
#import "ECDateViewFactory.h"


@interface ECDateViewFactoryTests : XCTestCase

@property (nonatomic, strong) ECDateViewFactory* dateViewFactory;

@property (nonatomic, strong) NSDate* testStartDate;

@end

@implementation ECDateViewFactoryTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];

    self.testStartDate = [NSDate date];
    self.dateViewFactory = [[ECDateViewFactory alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Testing
#pragma mark Creating Date Views

- (void)testDateViewFactoryCreatesDateView
{
    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
    
    XCTAssertNotNil(dateView);
}

- (void)testDateViewFactoryCreatesDateViewWithCorrectDate
{
    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    XCTAssertTrue([calendar isDate:dateView.date inSameDayAsDate:self.testStartDate], @"ECDateViewFactory should create a view with a date in the same day as the given date");
}

#pragma mark Testing Date View Properties

- (void)testDateViewIsTodaysDatePropertySet
{
    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    XCTAssertEqual([calendar isDateInToday:dateView.date], dateView.isTodaysDate);
}

- (void)testDateViewIsTodaysDatePropertyChanges
{
    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
    
    NSDate* yesterday = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:self.testStartDate options:0];
    
    [self.dateViewFactory configureDateView:dateView forDate:yesterday];
    XCTAssertFalse(dateView.isTodaysDate);
}

- (void)testDateViewUnselectedByDefault
{
    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
    
    XCTAssertFalse(dateView.isSelectedDate);
}

- (void)testSelectingDateViewChangesIsSelectedProperty
{
    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
    
    [dateView setSelectedDate:YES animated:NO];
    XCTAssertTrue(dateView.isSelectedDate);
}

@end
