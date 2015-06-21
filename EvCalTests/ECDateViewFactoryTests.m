//
//  ECDateViewFactoryTests.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
#import <XCTest/XCTest.h>

// Helpers
#import "NSDate+CupertinoYankee.h"

// EvCal Classes
#import "ECEventStoreProxy.h"
#import "ECDateView.h"
#import "ECDateViewFactory.h"
#import "ECCalendarIcon.h"


@interface ECDateViewFactoryTests : XCTestCase

@property (nonatomic, strong) ECEventStoreProxy* eventStoreProxy;

@property (nonatomic, strong) ECDateViewFactory* dateViewFactory;

@property (nonatomic, strong) NSDate* testStartDate;

@end

@implementation ECDateViewFactoryTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];

    self.testStartDate = [NSDate date];
    self.dateViewFactory = [[ECDateViewFactory alloc] init];
    self.eventStoreProxy = [[ECEventStoreProxy alloc] init];
}

- (void)tearDown
{
    self.eventStoreProxy = nil;
    self.dateViewFactory = nil;
    self.testStartDate = nil;
    
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

//- (void)testDateViewIsTodaysDatePropertyChanges
//{
//    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
//    
//    NSDate* yesterday = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:self.testStartDate options:0];
//    
//    [self.dateViewFactory configureDateView:dateView forDate:yesterday];
//    XCTAssertFalse(dateView.isTodaysDate);
//}

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

#pragma mark Testing Date View Accessory Views

//- (void)testDateViewHasCorrectNumberOfAccessoryViews
//{
//    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
//    
//    // Count calendars with events in them
//    NSInteger count = 0;
//    for (EKCalendar* calendar in self.eventStoreProxy.calendars) {
//        if ([self.eventStoreProxy eventsFrom:[self.testStartDate beginningOfDay] to:[self.testStartDate endOfDay] in:@[calendar]]) {
//            count++;
//        }
//    }
//    
//    XCTAssertEqual(count, dateView.eventAccessoryViews.count, @"Date view should have the same number of accessory views as the user has calendars with events");
//}

@end
