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
@import Tunits;
#import "ECTestsEventFactory.h"

// EvCal Classes
#import "ECEventStoreProxy.h"
#import "ECDayView.h"
#import "ECEventView.h"

@interface ECEventViewTests : XCTestCase

@property (nonatomic, strong) ECDayView* dayView;
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) EKCalendar* testCalendar;
@property (nonatomic, strong) TimeUnit* tunit;
@property (nonatomic, strong) NSDate* testStartDate;
@property (nonatomic) CGRect testFrame;

@end

@implementation ECEventViewTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
    self.tunit = [[TimeUnit alloc] init];
    self.testStartDate = [NSDate date];
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
    
    self.tunit = nil;
    self.testStartDate = nil;
    self.dayView = nil;
    self.eventStore = nil;
}


#pragma mark - Helpers

- (EKEvent*)createEventWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate allDay:(BOOL)allDay
{
    EKEvent* event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = @"Test Event View Creation";
    event.location = @"Simulator/iOS Device";
    event.startDate = startDate;
    event.endDate = endDate;
    event.allDay = allDay;
    event.calendar = self.testCalendar;
    
    return event;
}

- (ECEventView*)createEventViewWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate allDay:(BOOL)allDay
{
    return [[ECEventView alloc] initWithEvent:[self createEventWithStartDate:startDate endDate:endDate allDay:allDay]];
}

#pragma mark - Tests

- (void)testEventViewsCanBeCreated
{
    ECEventView* eventView = [self createEventViewWithStartDate:self.testStartDate endDate:[self.tunit endOfHour:self.testStartDate] allDay:NO];
    
    XCTAssertNotNil(eventView);
}

- (void)testEventViewCreatedWithCorrectEvent
{
    EKEvent* event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = @"Test Event View Creation";
    event.location = @"Simulator/iOS Device";
    event.startDate = self.testStartDate;
    event.endDate = [self.tunit endOfHour:self.testStartDate];
    event.allDay = NO;
    event.calendar = self.testCalendar;
    
    ECEventView* eventView = [[ECEventView alloc] initWithEvent:event];
    XCTAssertEqualObjects(eventView.event, event);
}

- (void)testEventViewCompareForEventsWithAscendingStartAndEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* firstEventStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* firstEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:firstEventStartDate options:0];
    NSDate* secondEventStartDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:firstEventEndDate options:0];
    NSDate* secondEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:secondEventStartDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:firstEventStartDate endDate:firstEventEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:secondEventStartDate endDate:secondEventEndDate  allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedAscending);
}

- (void)testEventViewCompareForEventsWithAscendingStartAndSameEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* firstEventStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* secondEventStartDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:firstEventStartDate options:0];
    NSDate* eventsEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:2 toDate:firstEventStartDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:firstEventStartDate endDate:eventsEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:secondEventStartDate endDate:eventsEndDate allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedAscending);
}

- (void)testEventViewCompareForEventsWithAscendingStartAndDescendingEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* firstEventStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* firstEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:3 toDate:firstEventStartDate options:0];
    NSDate* secondEventStartDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:firstEventStartDate options:0];
    NSDate* secondEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:secondEventStartDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:firstEventStartDate endDate:firstEventEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:secondEventStartDate endDate:secondEventEndDate  allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedAscending);
}

- (void)testEventViewCompareWithSameStartAndAscendingEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* eventsStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* firstEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:eventsStartDate options:0];
    NSDate* secondEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:2 toDate:eventsStartDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:eventsStartDate endDate:firstEventEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:eventsStartDate endDate:secondEventEndDate  allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedAscending);
}


- (void)testEventViewCompareWithSameStartAndEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* eventsStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* eventsEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:eventsStartDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:eventsStartDate endDate:eventsEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:eventsStartDate endDate:eventsEndDate  allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedSame);
}

- (void)testEventViewCompareWithSameStartAndDescendingEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* eventsStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* firstEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:2 toDate:eventsStartDate options:0];
    NSDate* secondEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:eventsStartDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:eventsStartDate endDate:firstEventEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:eventsStartDate endDate:secondEventEndDate  allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedDescending);
}

- (void)testEventViewCompareWithDescendingStartAndAscendingEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* firstEventStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* firstEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:firstEventStartDate options:0];
    NSDate* secondEventStartDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:-1 toDate:firstEventStartDate options:0];
    NSDate* secondEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:firstEventEndDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:firstEventStartDate endDate:firstEventEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:secondEventStartDate endDate:secondEventEndDate  allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedDescending);
}

- (void)testEventViewCompareWithDescendingStartAndSameEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* firstEventStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* secondEventStartDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:-1 toDate:firstEventStartDate options:0];
    NSDate* eventsEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:firstEventStartDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:firstEventStartDate endDate:eventsEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:secondEventStartDate endDate:eventsEndDate allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedDescending);
}

- (void)testEventViewCompareWithDescendingStartAndEndDates
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* firstEventStartDate = [self.tunit beginningOfHour:self.testStartDate];
    NSDate* firstEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:firstEventStartDate options:0];
    NSDate* secondEventStartDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:-2 toDate:firstEventStartDate options:0];
    NSDate* secondEventEndDate = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:secondEventStartDate options:0];
    
    ECEventView* earlyEventView = [self createEventViewWithStartDate:firstEventStartDate endDate:firstEventEndDate allDay:NO];
    ECEventView* laterEventView = [self createEventViewWithStartDate:secondEventStartDate endDate:secondEventEndDate  allDay:NO];
    
    XCTAssertTrue([earlyEventView compare:laterEventView] == NSOrderedDescending);
}
@end
