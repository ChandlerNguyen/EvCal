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

- (void)testEventViewCreation
{
    ECEventView* eventView = [self createSingleEventView];
    
    XCTAssertNotNil(eventView);
    XCTAssertTrue(CGRectEqualToRect(eventView.frame, CGRectZero));
    XCTAssertTrue([eventView.event.title isEqualToString:@"Test Event View Creation"]);
    XCTAssertTrue([eventView.event.location isEqualToString:@"Simulator/iOS Device"]);
    XCTAssertTrue([eventView.event.startDate isEqualToDate:[self.currentTestStartDate beginningOfDay]]);
    XCTAssertTrue([eventView.event.endDate isEqualToDate:[self.currentTestStartDate endOfDay]]);
    XCTAssertTrue([eventView.backgroundColor isEqual:[UIColor colorWithCGColor:eventView.event.calendar.CGColor]]);
}

- (void)testAddingNilAndEmptyEvents
{
    [self.dayView addEventView:nil];
    XCTAssert(self.dayView.eventViews.count == 0);
    
    [self.dayView addEventViews:nil];
    XCTAssert(self.dayView.eventViews.count == 0);
    
    [self.dayView addEventViews:@[]];
    XCTAssert(self.dayView.eventViews.count == 0);
}

- (void)testAddingSingleEventView
{
    ECEventView* eventView = [self createSingleEventView];
    
    [self.dayView addEventView:eventView];
    XCTAssert(self.dayView.eventViews.count == 1);
}

- (void)testRemovingSingleEventView
{
    ECEventView* eventView = [self createSingleEventView];
    
    [self.dayView addEventView:eventView];
    [self.dayView removeEventView:eventView];
    XCTAssertTrue(self.dayView.eventViews.count == 0);
}

- (void)testRemovingEventViewThatIsNotInDayView
{
    NSInteger eventViewCount = 2;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    NSInteger eventViewIndex = (NSInteger)arc4random_uniform((u_int32_t)eventViewCount);
    NSInteger nextEventViewIndex = (eventViewIndex + 1) % eventViewCount;
    
    // Add random event view
    [self.dayView addEventView:eventViews[eventViewIndex]];
    [self.dayView removeEventView:eventViews[nextEventViewIndex]];
    XCTAssertTrue(self.dayView.eventViews.count == 1);
}

- (void)testAddingMultipleEventViews
{
    NSInteger eventViewCount = 10;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    [self.dayView addEventViews:eventViews];
    XCTAssert(self.dayView.eventViews.count == eventViewCount);
}

- (void)testRemovingMultipleEventViews
{
    NSInteger eventViewCount = 10;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    [self.dayView addEventViews:eventViews];
    
    NSArray* eventViewsSubset = [eventViews objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, eventViewCount / 2)]];
    [self.dayView removeEventViews:eventViewsSubset];
    
    NSSet* dayViewEventViews = [NSSet setWithArray:self.dayView.eventViews];
    NSSet* removedEventViews = [NSSet setWithArray:eventViewsSubset];
    
    XCTAssert(self.dayView.eventViews.count == (eventViewCount - eventViewsSubset.count));
    XCTAssertFalse([dayViewEventViews intersectsSet:removedEventViews]);
}

- (void)testRemovingEventViewsThatAreNotInDayView
{
    NSInteger eventViewCount = 10;
    NSArray* addedEventViews = [self createMultipleEventViews:eventViewCount];
    NSArray* notAddedEventViews = [self createMultipleEventViews:eventViewCount];

    [self.dayView addEventViews:addedEventViews];
    [self.dayView removeEventViews:notAddedEventViews];

    XCTAssert(self.dayView.eventViews.count == eventViewCount);
}

- (void)testRemovingEventViewsWithMixedDayViewMembership
{
    NSInteger eventViewCount = 10;
    NSArray* addedEventViews = [self createMultipleEventViews:eventViewCount];
    NSArray* notAddedEventViews = [self createMultipleEventViews:eventViewCount];
    
    NSIndexSet* halfOfArrayIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, eventViewCount / 2)];
    NSArray* mixedEventViews = [[addedEventViews objectsAtIndexes:halfOfArrayIndexSet] arrayByAddingObjectsFromArray:[notAddedEventViews objectsAtIndexes:halfOfArrayIndexSet]];
    
    [self.dayView addEventViews:addedEventViews];
    [self.dayView removeEventViews:mixedEventViews];
    
    XCTAssert(self.dayView.eventViews.count == eventViewCount / 2);
}

- (void)testClearingEventViews
{
    NSInteger eventViewCount = 10;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    NSInteger eventViewIndex = (NSInteger)arc4random_uniform((u_int32_t)eventViewCount);
    
    [self.dayView addEventView:eventViews[eventViewIndex]];
    [self.dayView clearEventViews];
    XCTAssert(self.dayView.eventViews.count == 0);

}

- (void)testEventViewManagement
{
    NSInteger eventViewCount = 10;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    NSInteger eventViewIndex = (NSInteger)arc4random_uniform((u_int32_t)eventViewCount);
    NSInteger nextEventViewIndex = (eventViewIndex + 1) % eventViewCount;
 
    // Remvoe event view
    [self.dayView removeEventView:eventViews[eventViewIndex]];
    XCTAssert(self.dayView.eventViews.count == 0);
    
    [self.dayView addEventViews:eventViews];
    XCTAssert(self.dayView.eventViews.count == eventViewCount);
    XCTAssertTrue([self.dayView.eventViews hasSameElements:eventViews]);
    
    [self.dayView removeEventView:eventViews[eventViewIndex]];
    XCTAssert(self.dayView.eventViews.count == eventViewCount - 1);
    
    // remove the event already removed and one more
    [self.dayView removeEventViews:@[eventViews[eventViewIndex], eventViews[nextEventViewIndex]]];
    XCTAssert(self.dayView.eventViews.count == eventViewCount - 2);
    
    [self.dayView clearEventViews];
    XCTAssert(self.dayView.eventViews.count == 0);
}

- (void)testEventViewLayout
{
    XCTFail(@"Not implemented yet");
}

@end
