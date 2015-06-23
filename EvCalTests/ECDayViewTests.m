//
//  ECDayViewTests.m
//  EvCal
//
//  Created by Tom on 6/23/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// Frameworks
#import <XCTest/XCTest.h>
@import EventKit;

// Helpers
#import "NSDate+CupertinoYankee.h"

// EvCal Classes
#import "ECDayView.h"
#import "ECEventView.h"

@interface ECDayViewTests : XCTestCase <ECDayViewDataSource, ECDayViewDelegate>

@property (nonatomic, strong) NSDate* testStartDate;
@property (nonatomic, strong) ECDayView* dayView;

@property (nonatomic, strong) EKEventStore* eventStore;

@property (nonatomic) BOOL eventsRequested;
@property (nonatomic) BOOL contentSizeRequested;
@property (nonatomic) BOOL dayViewScrolledCalled;
@property (nonatomic) BOOL dayViewTimeScrolledCalled;

@end

@implementation ECDayViewTests

#pragma mark - Setup & Tear down

- (void)setUp {
    [super setUp];
   
    self.testStartDate = [NSDate date];
    
    self.dayView = [[ECDayView alloc] initWithFrame:CGRectZero displayDate:self.testStartDate];
    self.dayView.dayViewDataSource = self;
    self.dayView.dayViewDelegate = self;
    
    self.dayViewScrolledCalled = NO;
    self.dayViewTimeScrolledCalled = NO;
    self.eventsRequested = NO;
    self.contentSizeRequested = NO;
}

- (void)tearDown {
    
    self.dayView = nil;
    self.testStartDate = nil;
    self.eventStore = nil;
    
    [super tearDown];
}

#pragma mark - Day view data source and delegate

- (NSArray*)dayView:(ECDayView *)dayView eventsForDate:(NSDate *)date
{
    if (!self.eventStore) {
        self.eventStore = [[EKEventStore alloc] init];
    }
    self.eventsRequested = YES;
    NSArray* events = [self.eventStore eventsMatchingPredicate:[self.eventStore predicateForEventsWithStartDate:[date beginningOfDay]
                                                                                                        endDate:[date endOfDay]
                                                                                                      calendars:nil]];
    return events;
}

- (CGSize)contentSizeForDayView:(ECDayView *)dayView
{
    self.contentSizeRequested = YES;
    return CGSizeZero;
}

- (void)dayView:(ECDayView *)dayView didScrollFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    self.dayViewScrolledCalled = YES;
}

- (void)dayViewDidScrollTime:(ECDayView *)dayView
{
    self.dayViewTimeScrolledCalled = YES;
}

#pragma mark - Tests

- (void)testDayViewIsCreated
{
    XCTAssertNotNil(self.dayView);
}

- (void)testDayViewHasCorrectDisplayDate
{
    XCTAssertTrue([[NSCalendar currentCalendar] isDate:self.testStartDate inSameDayAsDate:self.dayView.displayDate]);
}

- (void)testDayViewRequestsPageView
{
    XCTAssertTrue(self.eventsRequested);
}

- (void)testDayViewRequestsContentSize
{
    XCTAssertTrue(self.contentSizeRequested);
}

- (void)testDayViewScrollToDateChangesDisplayDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* scrollToDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:self.testStartDate options:0];
    [self.dayView scrollToDate:scrollToDate animated:NO];
    
    XCTAssertTrue([calendar isDate:scrollToDate inSameDayAsDate:self.dayView.displayDate]);
}

- (void)testDayViewRefreshCalendarEventsRequestsEvents
{
    self.eventsRequested = NO;
    [self.dayView refreshCalendarEvents];
    
    XCTAssertTrue(self.eventsRequested);
}

- (void)testDayViewRefreshCalendarEventsDoesNotRequestContentSize
{
    self.contentSizeRequested = NO;
    [self.dayView refreshCalendarEvents];
   
    XCTAssertFalse(self.contentSizeRequested);
}

- (void)testDayViewRefreshCalendarEventsDoesNotChangeDisplayDate
{
    [self.dayView refreshCalendarEvents];
    
    XCTAssertTrue([[NSCalendar currentCalendar] isDate:self.testStartDate inSameDayAsDate:self.dayView.displayDate]);
}


@end
