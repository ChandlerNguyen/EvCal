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
#import "EKEvent+ECAdditions.h"

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
    XCTAssertNotNil(self.eventCache, @"Event cache should be initialized");
}

- (void)testCacheDataSourceSetCorrectly
{
    XCTAssertEqualObjects(self, self.eventCache.cacheDataSource, @"Event cache data source should be set");
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
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqualObjects(cacheEvents, storeEvents, @"Event cache should return the same events as the event store");
}

- (void)testCacheReturnsSameEventsAsEventStoreForDatePrecedingPreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* startOfPreviousMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:startOfMonth options:0];
    
    // initializes cache with a month of events
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    // grab events for month preceding intialized month
    NSArray* cacheEvents = [self.eventCache eventsFrom:startOfPreviousMonth to:startOfMonth in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startOfPreviousMonth endDate:startOfMonth calendars:nil];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqual(cacheEvents.count, storeEvents.count, @"Event cache should return the same events as the event store");
    for (EKEvent* event in storeEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should return the same events as the event store");
    }
}

- (void)testCacheReturnsSameEventsAsEventStoreForEndDateFollowingPreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* endOfNextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:endOfMonth options:0];
    
    // initialize cache with a month of events
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    // grab events for month following initalized month
    NSArray* cacheEvents = [self.eventCache eventsFrom:endOfMonth to:endOfNextMonth in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:endOfMonth endDate:endOfNextMonth calendars:nil];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqual(cacheEvents.count, storeEvents.count, @"Event cache should return the same events as the event store");
    for (EKEvent* event in storeEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should return the same events as the event store");
    }
}

- (void)testCacheReturnsSameEventsAsEventStoreForStartAndEndDateThatPrecedePreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* startOfTwoMonthsAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-2 toDate:startOfMonth options:0];
    NSDate* endOfTwoMonthsAgo = [startOfTwoMonthsAgo endOfMonth];
    
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:startOfTwoMonthsAgo to:endOfTwoMonthsAgo in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startOfTwoMonthsAgo endDate:endOfTwoMonthsAgo calendars:nil];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqual(cacheEvents.count, storeEvents.count, @"Event cache should return the same events as the event store");
    for (EKEvent* event in storeEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should return the same events as the event store");
    }
}

- (void)testCacheReturnsSameEventsAsEventStoreForStartDatePrecedingAndEndDateWithinPreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* previousMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:startOfMonth options:0];
    NSDate* twoDaysIntoMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:2 toDate:startOfMonth options:0];
    
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:previousMonth to:twoDaysIntoMonth in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:previousMonth endDate:twoDaysIntoMonth calendars:nil];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqual(cacheEvents.count, storeEvents.count, @"Event cache should return the same events as the event store");
    for (EKEvent* event in storeEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should return the same events as the event store");
    }
}

- (void)testCacheReturnsSameEventAsEventStoreForStartAndEndDateWithinPreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* twoDaysIntoMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:2 toDate:startOfMonth options:0];
    NSDate* tenDaysIntoMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:startOfMonth options:0];
    
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:twoDaysIntoMonth to:tenDaysIntoMonth in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:twoDaysIntoMonth endDate:tenDaysIntoMonth calendars:nil];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqual(cacheEvents.count, storeEvents.count, @"Event cache should return the same events as the event store");
    for (EKEvent* event in storeEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should return the same events as the event store");
    }
}

- (void)testCacheReturnsSameEventAsEventStoreForStartDateWithinAndEndDateFollowingPreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* twoDaysBeforeEndOfMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-2 toDate:endOfMonth options:0];
    NSDate* endOfNextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:endOfMonth options:0];
    
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:twoDaysBeforeEndOfMonth to:endOfNextMonth in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:twoDaysBeforeEndOfMonth endDate:endOfNextMonth calendars:nil];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqual(cacheEvents.count, storeEvents.count, @"Event cache should return the same events as the event store");
    for (EKEvent* event in storeEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should return the same events as the event store");
    }
}

- (void)testcacheReturnsSameEventAsEventStoreForStartAndDateFollowingPreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* startOfNextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:2 toDate:endOfMonth options:0];
    NSDate* endOfNextMonth = [startOfNextMonth endOfMonth];
    
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:startOfNextMonth to:endOfNextMonth in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startOfNextMonth endDate:endOfNextMonth calendars:nil];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqual(cacheEvents.count, storeEvents.count, @"Event cache should return the same events as the event store");
    for (EKEvent* event in storeEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should return the same events as the event store");
    }
}

- (void)testCacheReturnsSameEventAsEventStoreForStartDatePrecedingAndEndDateFollowingPreviousDateRange
{
    NSDate* startOfMonth = [self.testStartDate beginningOfMonth];
    NSDate* endOfMonth = [self.testStartDate endOfMonth];
    NSDate* startOfPreviousMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:startOfMonth options:0];
    NSDate* endOfNextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:endOfMonth options:0];
    
    [self.eventCache eventsFrom:startOfMonth to:endOfMonth in:nil];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:startOfPreviousMonth to:endOfNextMonth in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startOfPreviousMonth endDate:endOfNextMonth calendars:nil];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqual(cacheEvents.count, storeEvents.count, @"Event cache should return the same events as the event store");
    for (EKEvent* event in storeEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should return the same events as the event store");
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
    
    XCTAssertNil([self.eventCache eventsFrom:self.testStartDate to:dayBeforeTestStart in:nil]);
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
