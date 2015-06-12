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
@property (nonatomic, strong) NSMutableArray* createdEvents;
@property (nonatomic, strong) NSDate* testStartDate;

@property (nonatomic) CGFloat minimumHeight;
@property (nonatomic) CGRect testBounds;
@property (nonatomic, strong) NSArray* eventViews;

@property (nonatomic) BOOL eventViewsRequested;
@property (nonatomic) BOOL eventViewBoundsRequested;
@property (nonatomic) BOOL displayDateRequested;

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
    self.displayDateRequested = NO;
    
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
    self.displayDateRequested = NO;

    for (EKEvent* event in self.createdEvents) {
        [self.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:nil];
    }
    
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
    
    [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
    [self.createdEvents addObject:event];
    
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

- (NSDate*)displayDateForLayout:(ECDayViewEventsLayout *)layout
{
    self.displayDateRequested = YES;
    return self.testStartDate;
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
    self.eventViews = @[[self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO]];
    
    [self.layout frameForEventView:self.eventViews.firstObject];
    XCTAssertTrue(self.eventViewBoundsRequested);
}

- (void)testEventViewLayoutAsksDataSourceForEventViews
{
    self.eventViews = @[[self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO]];
    
    [self.layout frameForEventView:self.eventViews.firstObject];
    XCTAssertTrue(self.eventViewsRequested);
}

- (void)testEventViewLayoutAsksDataSourceForDisplayDate
{
    ECEventView* eventView = [self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO];
    
    [self.layout frameForEventView:eventView];
    XCTAssertTrue(self.displayDateRequested);
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
    self.eventViews = @[[self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO]];
    
    [self.layout frameForEventView:self.eventViews.firstObject];
    [self.layout invalidateLayout];
    self.eventViewsRequested = NO;
    [self.layout frameForEventView:self.eventViews.firstObject];
    
    XCTAssertTrue(self.eventViewsRequested);
}

- (void)testEventViewLayoutRequestsNumberOfHoursAfterLayoutInvalidation
{
    self.eventViews = @[[self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO]];
    
    [self.layout frameForEventView:self.eventViews.firstObject];
    [self.layout invalidateLayout];
    self.displayDateRequested = NO;
    [self.layout frameForEventView:self.eventViews.firstObject];
    
    XCTAssertTrue(self.displayDateRequested);
}


#pragma mark Testing nil and zero cases
- (void)testEventViewLayoutReturnsZeroFrameIfEventIsNil
{
    XCTAssertTrue(CGRectEqualToRect(CGRectZero, [self.layout frameForEventView:nil]));
}

- (void)testEventViewLayoutReturnsZeroFrameIfBoundAreZero
{
    self.eventViews = @[[self createEventViewWithStartDate:self.testStartDate endDate:[self.testStartDate endOfHour] allDay:NO]];
    
    self.testBounds = CGRectZero;
    [self.layout invalidateLayout];
    
    XCTAssertTrue(CGRectEqualToRect(CGRectZero, [self.layout frameForEventView:self.eventViews.firstObject]));
}


#pragma mark Testing event layouts
//  12:00 AM *+----------------------+
//            | A                    |
//   1:00 AM *+----------------------+
//
//  A Frame {{0, 0}, {120, 100}}
- (void)testEventViewLayoutCreatesCorrectFrameForOneEvent
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* midnight = [self.testStartDate beginningOfDay];
    NSDate* oneAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:1 toDate:midnight options:0];

    self.eventViews = @[[self createEventViewWithStartDate:midnight endDate:oneAM allDay:NO]];
    
    CGRect eventViewFrame = [self.layout frameForEventView:self.eventViews.firstObject];
    XCTAssertTrue(CGRectEqualToRect(CGRectMake(0, 0, 120, 100), eventViewFrame));
}

//  Side by side events ***
//   2:00 AM *+----------++----------+
//            | A        || B        |
//   3:00 AM *+----------++----------+
//
//    A Frame {{?, 200}, {60, 100}}
//    B Frame {{?, 200}, {60, 100}}
- (void)testEventViewLayoutCreatesCorrectFrameForTwoOverlappingEvents
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDate* midnight = [self.testStartDate beginningOfDay];
    NSDate* twoAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:2 toDate:midnight options:0];
    NSDate* threeAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:3 toDate:midnight options:0];

    ECEventView* a = [self createEventViewWithStartDate:twoAM endDate:threeAM allDay:NO];
    ECEventView* b = [self createEventViewWithStartDate:twoAM endDate:threeAM allDay:NO];
    self.eventViews = @[a,b];
    
    CGRect aFrame = [self.layout frameForEventView:a];
    CGRect bFrame = [self.layout frameForEventView:b];

    XCTAssertTrue(aFrame.origin.y == 200 && CGSizeEqualToSize(aFrame.size, CGSizeMake(60, 100)) &&
                  bFrame.origin.y == 200 && CGSizeEqualToSize(bFrame.size, CGSizeMake(60, 100)) &&
                  !CGRectIntersectsRect(aFrame, bFrame));
}

//    *** Event view that overlaps with two non-overlapping event views ***
//     4:00 AM *+----------++----------+
//              | A        || B        |
//     5:00 AM  |          ++----------+
//              |          || C        |
//     6:00 AM  +----------++----------+
//
//    A Frame {{?, 400}, {60, 200}}
//    B Frame {{?, 400}, {60, 100}}
//    C Frame {{?, 500}, {60, 100}}
- (void)testEventViewLayoutCreatesCorrectFrameForOneEventOverlappingTwoNonOverlappingEvents
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDate* midnight = [self.testStartDate beginningOfDay];
    NSDate* fourAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:4 toDate:midnight options:0];
    NSDate* fiveAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:5 toDate:midnight options:0];
    NSDate* sixAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:6 toDate:midnight options:0];

    ECEventView* a = [self createEventViewWithStartDate:fourAM endDate:sixAM allDay:NO];
    ECEventView* b = [self createEventViewWithStartDate:fourAM endDate:fiveAM allDay:NO];
    ECEventView* c = [self createEventViewWithStartDate:fiveAM endDate:sixAM allDay:NO];
    self.eventViews = @[a,b,c];
    
    CGRect aFrame = [self.layout frameForEventView:a];
    CGRect bFrame = [self.layout frameForEventView:b];
    CGRect cFrame = [self.layout frameForEventView:c];
    
    XCTAssertTrue(aFrame.origin.y == 400 && CGSizeEqualToSize(aFrame.size, CGSizeMake(60, 200)) &&
                  bFrame.origin.y == 400 && CGSizeEqualToSize(bFrame.size, CGSizeMake(60, 100)) &&
                  cFrame.origin.y == 500 && CGSizeEqualToSize(cFrame.size, CGSizeMake(60, 100)) &&
                  !CGRectIntersectsRect(aFrame, bFrame) && !CGRectIntersectsRect(aFrame, cFrame) && !CGRectIntersectsRect(bFrame, cFrame));
}

//    *** Event view that overlaps with multiple event views that alternate overlap
//     7:00 AM *+----------++----------+
//              | A        || B        |
//     8:00 AM *|          |+----++----+
//              |          ||C   ||D   |
//     9:00 AM *+----------++----++----+
//
//     A Frame {{?, 700}, {60, 200}}
//     B Frame {{?, 700}, {60, 100}}
//     C Frame {{?, 800}, {30, 100}}
//     D Frame {{?, 800}, {30, 100}}
- (void)testEventViewLayoutCreatesCorrectFramesForNestedOverlappingEvents
{
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDate* midnight = [self.testStartDate beginningOfDay];
    NSDate* sevenAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:7 toDate:midnight options:0];
    NSDate* eightAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:8 toDate:midnight options:0];
    NSDate* nineAM = [calendar dateByAddingUnit:NSCalendarUnitHour value:9 toDate:midnight options:0];
    
    ECEventView* a = [self createEventViewWithStartDate:sevenAM endDate:nineAM allDay:NO];
    ECEventView* b = [self createEventViewWithStartDate:sevenAM endDate:eightAM allDay:NO];
    ECEventView* c = [self createEventViewWithStartDate:eightAM endDate:nineAM allDay:NO];
    ECEventView* d = [self createEventViewWithStartDate:eightAM endDate:nineAM allDay:NO];
    self.eventViews = @[a,b,c,d];
    
    CGRect aFrame = [self.layout frameForEventView:a];
    CGRect bFrame = [self.layout frameForEventView:b];
    CGRect cFrame = [self.layout frameForEventView:c];
    CGRect dFrame = [self.layout frameForEventView:d];
    
    NSLog(@"\nA Frame: %@\nB Frame: %@\nC Frame: %@\nD Frame: %@", NSStringFromCGRect(aFrame), NSStringFromCGRect(bFrame), NSStringFromCGRect(cFrame), NSStringFromCGRect(dFrame));
    
    XCTAssertTrue(aFrame.origin.y == 700 && CGSizeEqualToSize(aFrame.size, CGSizeMake(40, 200)) &&
                  bFrame.origin.y == 700 && CGSizeEqualToSize(bFrame.size, CGSizeMake(40, 100)) &&
                  cFrame.origin.y == 800 && CGSizeEqualToSize(cFrame.size, CGSizeMake(40, 100)) &&
                  dFrame.origin.y == 800 && CGSizeEqualToSize(dFrame.size, CGSizeMake(40, 100)) &&
                  !CGRectIntersectsRect(aFrame, bFrame) && !CGRectIntersectsRect(aFrame, cFrame) && !CGRectIntersectsRect(aFrame, dFrame) &&
                  !CGRectIntersectsRect(bFrame, cFrame) && !CGRectIntersectsRect(bFrame, dFrame) && !CGRectIntersectsRect(cFrame, dFrame));
}

@end
