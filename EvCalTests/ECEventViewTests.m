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

@interface ECEventViewTests : XCTestCase

@property (nonatomic, strong) ECDayView* dayView;
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) EKCalendar* testCalendar;
@property (nonatomic) CGRect testFrame;

@end

@implementation ECEventViewTests

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
    
    self.testFrame = CGRectMake(0, 0, 120, 2400);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [self.eventStore removeCalendar:self.testCalendar commit:YES error:nil];
    
    self.dayView = nil;
    self.eventStore = nil;
}


#pragma mark - Helpers

- (ECEventView*)createEventViewWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate allDay:(BOOL)allDay
{
    EKEvent* event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = @"Test Event View Creation";
    event.location = @"Simulator/iOS Device";
    event.startDate = startDate;
    event.endDate = endDate;
    event.allDay = allDay;
    event.calendar = self.testCalendar;
    
    return [[ECEventView alloc] initWithEvent:event];
}

#pragma mark - Tests

#pragma mark Height
- (void)testEventViewHeightForCGRectZero
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssert([eventView heightInRect:CGRectZero forDate:startDate] == 0);
}

- (void)testEventViewHeightForEventWithinDay
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssert([eventView heightInRect:self.testFrame forDate:startDate] == self.testFrame.size.height / 24);
}

- (void)testEventViewHeightForEventWithStartDateInPreviousDay
{
    // Start date is the the beginning of the previous day and end date is one
    // hour into the day
    NSDate* startDate = [[[NSDate date] yesterday] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:[[startDate tomorrow] beginningOfDay] options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssertEqualWithAccuracy([eventView heightInRect:self.testFrame forDate:endDate], self.testFrame.size.height / 24, 1);
}

- (void)testEventViewHeightForEventWithEndDateInFollowingDay
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:2 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssertEqualWithAccuracy([eventView heightInRect:self.testFrame forDate:startDate], self.testFrame.size.height, 1);
}

- (void)testEventHeightForAllDayEvent
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [startDate endOfDay];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:YES];
    
    XCTAssertEqual([eventView heightInRect:self.testFrame forDate:startDate], 0);
}

#pragma mark Position

- (void)testEventViewPositionForCGRectZeroIsZero
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssert([eventView verticalPositionInRect:self.testFrame forDate:startDate] == 0);
}

- (void)testEventViewPositionForDateAtStartOfDay
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssert([eventView verticalPositionInRect:self.testFrame forDate:startDate] == 0);
}

- (void)testEventViewPositionForDateLaterInDay
{
    NSDate* startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:[[NSDate date] beginningOfDay] options:0];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssertEqualWithAccuracy([eventView verticalPositionInRect:self.testFrame forDate:startDate], self.testFrame.origin.y + self.testFrame.size.height / 24, 1);
}

- (void)testEventViewPositionForRectWithNonZeroOrigin
{
    self.testFrame = CGRectMake(0, 100, self.testFrame.size.width, self.testFrame.size.height);
    
    NSDate* startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:[[NSDate date] beginningOfDay] options:0];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssertEqualWithAccuracy([eventView verticalPositionInRect:self.testFrame forDate:startDate], self.testFrame.origin.y + self.testFrame.size.height / 24, 1);
}

- (void)testEventViewPositionForStartDateBeforeDay
{
    NSDate* startDate = [[[NSDate date] yesterday] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:NO];
    
    XCTAssert([eventView verticalPositionInRect:self.testFrame forDate:[startDate tomorrow]] == 0);
}

- (void)testEventViewPositionForAllDayEvent
{
    NSDate* startDate = [[NSDate date] beginningOfDay];
    NSDate* endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:startDate options:0];
    
    ECEventView* eventView = [self createEventViewWithStartDate:startDate endDate:endDate allDay:YES];
    
    XCTAssert([eventView verticalPositionInRect:self.testFrame forDate:[startDate tomorrow]] == 0);
}

@end
