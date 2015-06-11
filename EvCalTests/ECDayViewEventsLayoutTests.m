//
//  ECDayViewEventsLayoutTests.m
//  EvCal
//
//  Created by Tom on 6/11/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
@import EventKit;
#import <XCTest/XCTest.h>

// Helpers
#import "NSDate+CupertinoYankee.h"

// EvCal Classes
#import "ECDayViewEventsLayout.h"
#import "ECEventView.h"

@interface ECDayViewEventsLayoutTests : XCTestCase <ECDayViewEventsLayoutDataSource>

@property (nonatomic, strong) ECDayViewEventsLayout* layout;

@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) EKCalendar* testCalendar;
@property (nonatomic, strong) NSDate* testStartDate;

@property (nonatomic) CGFloat minimumHeight;
@property (nonatomic) CGRect testBounds;
@property (nonatomic, strong) NSMutableArray* eventViews;

@property (nonatomic) BOOL eventViewsRequested;
@property (nonatomic) BOOL eventViewBoundsRequested;

@end

@implementation ECDayViewEventsLayoutTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
    self.testStartDate = [NSDate date];
    
    self.layout = [[ECDayViewEventsLayout alloc] init];
    self.layout.layoutDataSource = self;
    
    self.testBounds = CGRectMake(0, 0, 120, 2400);
    self.eventViewsRequested = NO;
    self.eventViewBoundsRequested = NO;
    
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

    self.testBounds = CGRectZero;
    self.minimumHeight = 0;
    self.layout = nil;
    self.eventViews = nil;
    
    [self.eventStore removeCalendar:self.testCalendar commit:YES error:nil];
    self.eventStore = nil;
    
    [super tearDown];
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


#pragma mark - ECDayViewEventsLayout Data Source

- (CGRect)layout:(ECDayViewEventsLayout *)layout boundsForEventViews:(NSArray *)eventViews
{
    self.eventViewBoundsRequested = YES;
    return self.testBounds;
}

- (NSArray*)eventViewsForLayout:(ECDayViewEventsLayout *)layout
{
    self.eventViewsRequested = YES;
    return self.eventViews;
}

- (CGFloat)minimumEventHeightForLayout:(ECDayViewEventsLayout *)layout
{
    return self.minimumHeight;
}


#pragma mark - Tests

- (void)testEventViewLayoutExists
{
    XCTAssertNotNil(self.layout);
}

- (void)testEventViewLayoutDataSourceSet
{
    XCTAssertEqualObjects(self.layout.layoutDataSource, self);
}

- (void)testEventViewLayoutAsksDataSourceForBounds
{
    ECEventView* eventView = [self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO];
    
    [self.layout frameForEventView:eventView];
    XCTAssertTrue(self.eventViewBoundsRequested);
}

- (void)testEventViewLayoutAsksDataSourceForEventViews
{
    ECEventView* eventView = [self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO];
    
    [self.layout frameForEventView:eventView];
    XCTAssertTrue(self.eventViewsRequested);
}

- (void)testEventViewLayoutRequestsBoundsAfterLayoutInvalidation
{
    ECEventView* eventView = [self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO];
    
    [self.layout frameForEventView:eventView];
    [self.layout invalidateLayout];
    self.eventViewBoundsRequested = NO;
    [self.layout frameForEventView:eventView];
    
    XCTAssertTrue(self.eventViewBoundsRequested);
}

- (void)testEventViewLayoutRequestsEventViewsAfterLayoutInvalidation
{
    ECEventView* eventView = [self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO];
    
    [self.layout frameForEventView:eventView];
    [self.layout invalidateLayout];
    self.eventViewsRequested = NO;
    [self.layout frameForEventView:eventView];
    
    XCTAssertTrue(self.eventViewsRequested);
}

- (void)testEventViewLayoutReturnsZeroFrameIfEventIsNil
{
    XCTAssertTrue(CGRectEqualToRect(CGRectZero, [self.layout frameForEventView:nil]));
}

- (void)testEventViewLayoutReturnsZeroFrameIfBoundAreZero
{
    self.testBounds = CGRectZero;
    [self.layout invalidateLayout];
    
    XCTAssertTrue(CGRectEqualToRect(CGRectZero, [self.layout frameForEventView:self.eventViews.firstObject]));
}

@end
