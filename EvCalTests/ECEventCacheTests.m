//
//  ECEventCacheTests.m
//  EvCal
//
//  Created by Tom on 6/30/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
@import EventKit;
#import <XCTest/XCTest.h>

// Helpers
#import "NSDate+CupertinoYankee.h"

// EvCal Classes
#import "ECEventCache.h"

@interface ECEventCacheTests : XCTestCase <ECEventCacheDataSource>

@property (nonatomic, strong) ECEventCache* eventCache;
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) NSDate* testStartDate;
@property (nonatomic, strong) EKCalendar* testCalendar;
@end

@implementation ECEventCacheTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
    self.testStartDate = [NSDate date];
    
    self.eventCache = [[ECEventCache alloc] init];
    self.eventCache.cacheDataSource = self;
    
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
    
    [self.eventStore removeCalendar:self.testCalendar commit:YES error:nil];
    self.testCalendar = nil;
    self.eventCache = nil;
    self.eventStore = nil;
    
    [super tearDown];
}


#pragma mark - Cache data source

- (NSArray*)storedEventsFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    
    return [self.eventStore eventsMatchingPredicate:eventsPredicate];
}


#pragma mark - Tests

- (void)testCacheCanBeCreated
{
    XCTAssertNotNil(self.eventCache);
}

- (void)testCacheDataSourceSetCorrectly
{
    XCTAssertEqualObjects(self, self.eventCache.cacheDataSource);
}

- (void)testCacheReturnsSameEventsAsEventStore
{
    NSDate* startDate = [self.testStartDate beginningOfYear];
    NSDate* endDate = [self.testStartDate endOfYear];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:[self.testStartDate beginningOfYear] to:[self.testStartDate endOfYear] in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray* eventStoreEvents = [self.eventStore eventsMatchingPredicate:eventsPredicate];
    
    XCTAssertEqual(cacheEvents.count, eventStoreEvents.count, @"Event cache should return the same number of events as the event store");
    for (EKEvent* event in eventStoreEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should contain all the elements from the event store");
    }
}

- (void)testCacheReturnsSameEventsAsEventStoreFromAGivenCalendar
{
    NSDate* startOfYear = [self.testStartDate beginningOfYear];
    NSDate* endOfYear = [self.testStartDate endOfYear];
    NSArray* cacheEvents = [self.eventCache eventsFrom:startOfYear to:endOfYear in:@[self.testCalendar]];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startOfYear endDate:endOfYear calendars:@[self.testCalendar]];
    NSArray* eventStoreEvents = [self.eventStore eventsMatchingPredicate:eventsPredicate];
    
    XCTAssertEqual(cacheEvents.count, eventStoreEvents.count, @"Event cache should return the same number of events as the event store");
    for (EKEvent* event in eventStoreEvents) {
        // check each event because no guarantee is made about the order of events from EKEventStore
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should load all the events from the given calendar");
    }
}

- (void)testCacheReturnsSameEventsAsEventStoreForDatePrecedingPreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* startOfPreviousMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:startOfMonth options:0];
    
    // initializes cache with a month of events
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    // grab events for month preceding intialized month
    NSArray* previousMonthCacheEvents = [self.eventCache eventsFrom:startOfPreviousMonth to:startOfMonth in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startOfPreviousMonth endDate:startOfMonth calendars:nil];
    NSArray* previousMonthStoreEvents = [self.eventStore eventsMatchingPredicate:eventsPredicate];
    
    XCTAssertEqual(previousMonthCacheEvents.count, previousMonthStoreEvents.count, @"Event cache should contain the same number of events as the event store");
    for (EKEvent* event in previousMonthStoreEvents) {
        XCTAssertTrue([previousMonthCacheEvents containsObject:event], @"Event cache should contain all the events in the event store return");
    }
}

- (void)testCacheReturnsNilIfDataSourceNotSet
{
    NSDate* startOfYear = [self.testStartDate beginningOfYear];
    NSDate* endOfYear = [self.testStartDate endOfYear];
    self.eventCache.cacheDataSource = nil;
    
    XCTAssertNil([self.eventCache eventsFrom:startOfYear to:endOfYear in:nil], @"Event cache should always return nil if data source is not set");
}

- (void)testCacheReturnsNilIfStartDateNotProvided
{
    XCTAssertNil([self.eventCache eventsFrom:nil to:self.testStartDate in:nil]);
}

- (void)testCacheReturnsNilIfEndDateNotProvided
{
    XCTAssertNil([self.eventCache eventsFrom:self.testStartDate to:nil in:nil]);
}

- (void)testCacheReturnsNilIfStartDateFollowsEndDate
{
    NSDate* dayBeforeTestStart = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:self.testStartDate options:0];
    
    XCTAssertNil([self.eventCache eventsFrom:dayBeforeTestStart to:self.testStartDate in:nil]);
}

- (void)testCacheCanBeFlushed
{
    // Ensure that cache loads events
    NSDate* startOfYear = [self.testStartDate beginningOfYear];
    NSDate* endOfYear = [self.testStartDate endOfYear];
    [self.eventCache eventsFrom:startOfYear to:endOfYear in:nil];
    
    // Ensure data source method returns nil
    self.eventStore = nil;
    [self.eventCache flush];
    
    XCTAssertNil([self.eventCache eventsFrom:startOfYear to:endOfYear in:nil], @"Event cache should return nil after flushing with no data source");
}

@end
