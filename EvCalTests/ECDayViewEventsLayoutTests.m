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
@property (nonatomic, strong) NSArray* eventViews;

@property (nonatomic) BOOL eventViewsRequested;
@property (nonatomic) BOOL eventViewBoundsRequested;
@property (nonatomic) BOOL minimumHeightRequested;

@end

@implementation ECDayViewEventsLayoutTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
    // Grab start date
    self.testStartDate = [NSDate date];
    
    // Init layout
    self.layout = [[ECDayViewEventsLayout alloc] init];
    self.layout.layoutDataSource = self;
    
    // Test bounds designed for easy math
    self.testBounds = CGRectMake(0, 0, 120, 2400);
    self.minimumHeight = 0;
    
    // Data source method call booleans
    self.eventViewsRequested = NO;
    self.eventViewBoundsRequested = NO;
    self.minimumHeightRequested = NO;
    
    // Save events to this calendar for easier testing/removal
    self.eventStore = [[EKEventStore alloc] init];
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
    
    self.testStartDate = nil;
    self.layout = nil;
    self.eventViews = nil;
    
    self.testBounds = CGRectZero;
    self.minimumHeight = 0;

    self.eventViewsRequested = NO;
    self.eventViewBoundsRequested = NO;
    self.minimumHeightRequested = NO;

    [self.eventStore removeCalendar:self.testCalendar commit:YES error:nil];
    self.testCalendar = nil;
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

// The following snippets create the displayed event views and demonstrates the
// appropriate configuration and provides the proper frames with the default
// test bounds.
//
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    
//    *** Standalone event view ***
//    12:00 AM *+----------------------+
//              | A                    |
//     1:00 AM *+----------------------+
//
//    A Frame {{0, 0}, {120, 100}}
//    
//    NSDate* midnight = [self.testStartDate beginningOfDay];
//    NSDate* oneAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:midnight options:0];
//    
//    self.eventViews = @[[self createEventViewWithStartDate:midnight endDate:oneAM allDay:NO]];
//
//
//    *** Side by side events ***
//     2:00 AM *+----------++----------+
//              | A        || B        |
//     3:00 AM *+----------++----------+
//    NSDate* twoAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:2 toDate:midnight options:0];
//    NSDate* threeAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:3 toDate:midnight options:0];
//
//    self.eventViews = @[[self createEventViewWithStartDate:twoAM endDate:threeAM allDay:NO],
//                        [self createEventViewWithStartDate:twoAM endDate:threeAM allDay:NO]];
//
//    A Frame {{200, 0}, {60, 100}}
//    B Frame {{200, 60}, {60, 100}}
//
//    *** Event view that overlaps with two non-overlapping event views ***
//     4:00 AM *+----------++----------+
//              | A        || B        |
//     5:00 AM  |          ++----------+
//              |          || C        |
//     6:00 AM  +----------++----------+
//    NSDate* fourAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:4 toDate:midnight options:0];
//    NSDate* fiveAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:5 toDate:midnight options:0];
//    NSDate* sixAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:6 toDate:midnight options:0];
//
//    self.eventViews = @[[self createEventViewStartDate:fourAM endDate:sixAM allDay:NO],
//                        [self createEventViewStartDate:fourAM endDate:fiveAM allDay:NO],
//                        [self createEventViewStartDate:fiveAM endDate:sixAM allDay:NO]];
//
//    A Frame {{400, 0}, {60, 200}}
//    B Frame {{400, 60}, {60, 100}}
//    C Frame {{500, 60}, {60, 100}}
//
//    *** Event view that overlaps with multiple event views that alternate overlap
//     7:00 AM *+----------++----------+
//              | A        || B        |
//     8:00 AM *|          |+----++----+
//              |          ||C   ||D   |
//     9:00 AM *+----------++----++----+
//
//     A Frame {{700, 0}, {60, 200}}
//     B Frame {{700, 60}, {60, 100}}
//     C Frame {{800, 60}, {30, 100}}
//     D Frame {{800, 90}, {30, 100}}
//



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
    self.minimumHeightRequested = YES;
    return self.minimumHeight;
}


#pragma mark - Tests

#pragma mark Testing Initialization
- (void)testEventViewLayoutExists
{
    XCTAssertNotNil(self.layout);
}

- (void)testEventViewLayoutDataSourceSet
{
    XCTAssertEqualObjects(self.layout.layoutDataSource, self);
}

#pragma mark Testing Data Source calls
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


#pragma mark Testing nil and zero cases
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
