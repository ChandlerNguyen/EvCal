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
#pragma mark Creating single date view

- (void)testDateViewFacotryCreated
{
    XCTAssertNotNil(self.dateViewFactory);
}

- (void)testDateViewFactoryReturnsNilIfDateNil
{
    ECDateView* dateView = [self.dateViewFactory dateViewForDate:nil];
    
    XCTAssertNil(dateView);
}

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

#pragma mark Creating multiple views

- (void)testDateViewFactoryReturnsNilIfDatesNil
{
    NSArray* dateViews = [self.dateViewFactory dateViewsForDates:nil reusingViews:nil];
    
    XCTAssertNil(dateViews);
}

#define DATE_VIEWS_COUNT    5
- (void)testDateViewFactoryCreatesDateViewsInCorrectOrder
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSMutableArray* mutableDates = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < DATE_VIEWS_COUNT; i++) {
        NSDate* date = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:self.testStartDate options:0];
        [mutableDates addObject:date];
    }
    
    NSArray* dateViews = [self.dateViewFactory dateViewsForDates:mutableDates reusingViews:nil];
    BOOL datesMismatched = NO;
    for (NSInteger i = 0; i < dateViews.count; i++) {
        NSDate* testDate = mutableDates[i];
        NSDate* dateViewDate = ((ECDateView*)dateViews[i]).date;
        
        if (![[NSCalendar currentCalendar] isDate:testDate inSameDayAsDate:dateViewDate]) {
            datesMismatched = YES;
        }
    }
    
    XCTAssertFalse(datesMismatched);
}

- (void)testDateViewFactoryCreatesMultipleDateViewsWithNoReusableViews
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSMutableArray* mutableDates = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < DATE_VIEWS_COUNT; i++) {
        NSDate* date = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:self.testStartDate options:0];
        [mutableDates addObject:date];
    }
    
    NSArray* dateViews = [self.dateViewFactory dateViewsForDates:mutableDates reusingViews:nil];
    XCTAssertEqual(dateViews.count, mutableDates.count);
}

- (void)testDateViewFactoryReusesDateView
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    ECDateView* dateView = [self.dateViewFactory dateViewForDate:self.testStartDate];
    NSDate* testDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:self.testStartDate options:0];
    
    [self.dateViewFactory dateViewsForDates:@[testDate] reusingViews:@[dateView]];
    XCTAssertTrue([calendar isDate:dateView.date inSameDayAsDate:testDate]); // event view should be updated
}

@end
