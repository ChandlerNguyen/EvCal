//
//  ECDayViewLayoutTests.m
//  EvCal
//
//  Created by Tom on 5/23/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
@import EventKit;
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// Helpers
#import "NSArray+ECTesting.h"
#import "NSDate+CupertinoYankee.h"
#import "ECTestsEventFactory.h"

// EvCal Classes
#import "ECEventStoreProxy.h"
#import "ECDayView.h"
#import "ECEventView.h"

@interface ECDayViewLayoutTests : XCTestCase

@property (nonatomic, strong) ECDayView* dayView;
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) EKCalendar* testCalendar;
@property (nonatomic, strong) NSDate* currentTestStartDate;

@end

@implementation ECDayViewLayoutTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];

    self.currentTestStartDate = [NSDate date];
    
    self.dayView = [[ECDayView alloc] initWithFrame:CGRectZero];
    self.eventStore = [[EKEventStore alloc] init];
    
    // Save events to this calendar for easier testing/removal
    self.testCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
    
    EKSource* local = nil;
    for (EKSource* source in self.eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            local = source;
            break;
        }
    }
    self.testCalendar.source = local;
    self.testCalendar.title = @"Test Calendar";
    [self.eventStore saveCalendar:self.testCalendar commit:YES error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [self.eventStore removeCalendar:self.testCalendar commit:YES error:nil];
    
    self.dayView = nil;
    self.eventStore = nil;
}


#pragma mark - Helpers

- (ECEventView*)createSingleEventView
{
    EKEvent* event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = @"Test Event View Creation";
    event.location = @"Simulator/iOS Device";
    event.startDate = [self.currentTestStartDate beginningOfDay];
    event.endDate = [event.startDate endOfDay];
    event.calendar = self.testCalendar;
    
    return [[ECEventView alloc] initWithEvent:event];
}

- (NSArray*)createMultipleEventViews:(NSInteger)count
{
    if (count > 0) {
        NSMutableArray* eventViews = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < count; i++) {
            [eventViews addObject:[[ECEventView alloc] initWithEvent:[ECTestsEventFactory randomEventInDay:self.currentTestStartDate
                                                                                                     store:self.eventStore
                                                                                                  calendar:self.testCalendar
                                                                                         allowMultipleDays:YES]]];
        }
        return [eventViews copy];
    } else {
        return @[];
    }
}

#pragma mark - Tests

- (void)testEventViewHeightForCGRectZero
{
    XCTFail(@"Not Implemented");
}

- (void)testEventViewHeightForEventWithin24HourDay
{
    XCTFail(@"Not Implemented");
}

- (void)testEventViewHeightForEventWtihinDaylightSavingsDay
{
    XCTFail(@"Not Implemented");
}

- (void)testEventViewHeightForEventWithStartDateInPreviousDay
{
    XCTFail(@"Not Implemented");
}

- (void)testEventViewHeightForEventWithEndDateInFollowingDay
{
    XCTFail(@"Not Implemented");
}

- (void)testEventViewHeightForEventThatSpansEntireDay
{
    XCTFail(@"Not Implemented");
}

- (void)testEventViewHeightForEventThatSpansMultipleDays
{
    XCTFail(@"Not Implemented");
}

@end
