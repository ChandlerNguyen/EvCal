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
@property (nonatomic) CGRect testFrame;

@end

@implementation ECDayViewLayoutTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
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
    
    self.testFrame = CGRectMake(0, 0, 1, 2400);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [self.eventStore removeCalendar:self.testCalendar commit:YES error:nil];
    
    self.dayView = nil;
    self.eventStore = nil;
}


#pragma mark - Helpers

- (ECEventView*)createEventViewWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    EKEvent* event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = @"Test Event View Creation";
    event.location = @"Simulator/iOS Device";
    event.startDate = startDate;
    event.endDate = endDate;
    event.calendar = self.testCalendar;
    
    return [[ECEventView alloc] initWithEvent:event];
}

#pragma mark - Tests

- (void)testEventViewHeightForCGRectZero
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate];
    
    XCTAssert([eventView heightInRect:CGRectZero forDate:startDate] == 0);
}

- (void)testEventViewHeightForEventWithinDay
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate];
    
    XCTAssert([eventView heightInRect:self.testFrame forDate:startDate] == self.testFrame.size.height / 24);
}

- (void)testEventViewHeightForEventWithStartDateInPreviousDay
{
    // Start date is the the beginning of the previous day and end date is one
    // hour into the day
    NSDate* startDate = [[[NSDate date] yesterday] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:[[startDate tomorrow] beginningOfDay] options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate];
    
    XCTAssertEqualWithAccuracy([eventView heightInRect:self.testFrame forDate:endDate], self.testFrame.size.height / 24, 1);
}

- (void)testEventViewHeightForEventWithEndDateInFollowingDay
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:2 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate];
    
    XCTAssertEqualWithAccuracy([eventView heightInRect:self.testFrame forDate:startDate], self.testFrame.size.height, 1);
}

@end
