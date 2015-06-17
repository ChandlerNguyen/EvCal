//
//  ECSinglesingleDayViewEventViewManagementTests.m
//  EvCal
//
//  Created by Tom on 5/26/15.
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
#import "ECSingleDayView.h"
#import "ECEventView.h"

@interface ECSingleDayViewEventViewManagementTests : XCTestCase

@property (nonatomic, strong) ECSingleDayView* singleDayView;
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) EKCalendar* testCalendar;
@property (nonatomic, strong) NSDate* currentTestStartDate;

@end

@implementation ECSingleDayViewEventViewManagementTests

- (void)setUp {
    [super setUp];
    
    self.currentTestStartDate = [NSDate date];
    
    self.singleDayView = [[ECSingleDayView alloc] initWithFrame:CGRectZero];
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
    
    self.singleDayView = nil;
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
}

- (void)testAddingNilAndEmptyEvents
{
    [self.singleDayView addEventView:nil];
    XCTAssert(self.singleDayView.eventViews.count == 0);
    
    [self.singleDayView addEventViews:nil];
    XCTAssert(self.singleDayView.eventViews.count == 0);
    
    [self.singleDayView addEventViews:@[]];
    XCTAssert(self.singleDayView.eventViews.count == 0);
}

- (void)testAddingSingleEventView
{
    ECEventView* eventView = [self createSingleEventView];
    
    [self.singleDayView addEventView:eventView];
    XCTAssert(self.singleDayView.eventViews.count == 1);
}

- (void)testRemovingSingleEventView
{
    ECEventView* eventView = [self createSingleEventView];
    
    [self.singleDayView addEventView:eventView];
    [self.singleDayView removeEventView:eventView];
    XCTAssertTrue(self.singleDayView.eventViews.count == 0);
}

- (void)testRemovingEventViewThatIsNotInsingleDayView
{
    NSInteger eventViewCount = 2;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    NSInteger eventViewIndex = (NSInteger)arc4random_uniform((u_int32_t)eventViewCount);
    NSInteger nextEventViewIndex = (eventViewIndex + 1) % eventViewCount;
    
    // Add random event view
    [self.singleDayView addEventView:eventViews[eventViewIndex]];
    [self.singleDayView removeEventView:eventViews[nextEventViewIndex]];
    XCTAssertTrue(self.singleDayView.eventViews.count == 1);
}

- (void)testAddingMultipleEventViews
{
    NSInteger eventViewCount = 10;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    [self.singleDayView addEventViews:eventViews];
    XCTAssert(self.singleDayView.eventViews.count == eventViewCount);
}

- (void)testRemovingMultipleEventViews
{
    NSInteger eventViewCount = 10;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    [self.singleDayView addEventViews:eventViews];
    
    NSArray* eventViewsSubset = [eventViews objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, eventViewCount / 2)]];
    [self.singleDayView removeEventViews:eventViewsSubset];
    
    NSSet* singleDayViewEventViews = [NSSet setWithArray:self.singleDayView.eventViews];
    NSSet* removedEventViews = [NSSet setWithArray:eventViewsSubset];
    
    XCTAssert(self.singleDayView.eventViews.count == (eventViewCount - eventViewsSubset.count));
    XCTAssertFalse([singleDayViewEventViews intersectsSet:removedEventViews]);
}

- (void)testRemovingEventViewsThatAreNotInsingleDayView
{
    NSInteger eventViewCount = 10;
    NSArray* addedEventViews = [self createMultipleEventViews:eventViewCount];
    NSArray* notAddedEventViews = [self createMultipleEventViews:eventViewCount];
    
    [self.singleDayView addEventViews:addedEventViews];
    [self.singleDayView removeEventViews:notAddedEventViews];
    
    XCTAssert(self.singleDayView.eventViews.count == eventViewCount);
}

- (void)testRemovingEventViewsWithMixedsingleDayViewMembership
{
    NSInteger eventViewCount = 10;
    NSArray* addedEventViews = [self createMultipleEventViews:eventViewCount];
    NSArray* notAddedEventViews = [self createMultipleEventViews:eventViewCount];
    
    NSIndexSet* halfOfArrayIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, eventViewCount / 2)];
    NSArray* mixedEventViews = [[addedEventViews objectsAtIndexes:halfOfArrayIndexSet] arrayByAddingObjectsFromArray:[notAddedEventViews objectsAtIndexes:halfOfArrayIndexSet]];
    
    [self.singleDayView addEventViews:addedEventViews];
    [self.singleDayView removeEventViews:mixedEventViews];
    
    XCTAssert(self.singleDayView.eventViews.count == eventViewCount / 2);
}

- (void)testClearingEventViews
{
    NSInteger eventViewCount = 10;
    NSArray* eventViews = [self createMultipleEventViews:eventViewCount];
    
    NSInteger eventViewIndex = (NSInteger)arc4random_uniform((u_int32_t)eventViewCount);
    
    [self.singleDayView addEventView:eventViews[eventViewIndex]];
    [self.singleDayView clearEventViews];
    XCTAssert(self.singleDayView.eventViews.count == 0);
}

@end
