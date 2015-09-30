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
@import Tunits;
#import "EKEvent+ECAdditions.h"

// EvCal Classes
#import "ECEventCache.h"

@interface ECEventCacheTests : XCTestCase <ECEventCacheDataSource>

@property (nonatomic, strong) ECEventCache* eventCache;
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) NSDate* testStartDate;
@property (nonatomic, strong) TimeUnit* tunit;
@property (nonatomic, strong) EKCalendar* testCalendar;
@end

@implementation ECEventCacheTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
    self.tunit = [[TimeUnit alloc] init];
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
    [self addEventsToTestCalendar];
}


- (void)tearDown {
    
    
    [self removeEventsFromTestCalendar];
    [self.eventStore removeCalendar:self.testCalendar commit:YES error:nil];
    self.tunit = nil;
    self.testStartDate = nil;
    self.testCalendar = nil;
    self.eventCache = nil;
    self.eventStore = nil;
    
    [super tearDown];
}

- (void)addEventsToTestCalendar
{
//    EKEvent* eventWithinDay = [EKEvent eventWithEventStore:self.eventStore];
//    eventWithinDay.title = @"Event Within Day";
//    eventWithinDay.startDate = [self.tunit beginningOfDay:self.testStartDate];
//    eventWithinDay.endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:eventWithinDay.startDate options:0];
//    eventWithinDay.calendar = self.testCalendar;
    
    EKEvent* eventSpanningMultipleDays = [EKEvent eventWithEventStore:self.eventStore];
    eventSpanningMultipleDays.title = @"Event Spanning Multiple Days";
    eventSpanningMultipleDays.startDate = [self.tunit beginningOfDay:self.testStartDate];
    eventSpanningMultipleDays.endDate = [self.tunit endOfDay:[self.tunit dayAfter:self.testStartDate]];
    eventSpanningMultipleDays.calendar = self.testCalendar;
    
    //[self.eventStore saveEvent:eventWithinDay span:EKSpanThisEvent commit:NO error:nil];
    [self.eventStore saveEvent:eventSpanningMultipleDays span:EKSpanThisEvent commit:NO error:nil];
    [self.eventStore commit:nil];
}

- (void)removeEventsFromTestCalendar
{
    NSArray* testEvents = [self.eventStore eventsMatchingPredicate:[self.eventStore predicateForEventsWithStartDate:[self.tunit beginningOfDay:self.testStartDate]
                                                                                                            endDate:[self.tunit endOfDay:[self.tunit dayAfter:self.testStartDate]]
                                                                                                          calendars:@[self.testCalendar]]];
    
    for (EKEvent* event in testEvents) {
        [self.eventStore removeEvent:event span:EKSpanThisEvent commit:NO error:nil];
    }
    [self.eventStore commit:nil];
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
    NSDate* startDate = [self.tunit beginningOfYear:self.testStartDate];
    NSDate* endDate = [self.tunit endOfYear:self.testStartDate];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:[self.tunit beginningOfYear:self.testStartDate] to:[self.tunit endOfYear:self.testStartDate] in:nil];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray* eventStoreEvents = [self.eventStore eventsMatchingPredicate:eventsPredicate];
    
    XCTAssertEqual(cacheEvents.count, eventStoreEvents.count, @"Event cache should return the same number of events as the event store");
    for (EKEvent* event in eventStoreEvents) {
        XCTAssertTrue([cacheEvents containsObject:event], @"Event cache should contain all the elements from the event store");
    }
}

- (void)testCacheReturnsSameEventsAsEventStoreFromAGivenCalendar
{
    NSDate* startOfYear = [self.tunit beginningOfYear:self.testStartDate];
    NSDate* endOfYear = [self.tunit endOfYear:self.testStartDate];
    NSArray* cacheEvents = [self.eventCache eventsFrom:startOfYear to:endOfYear in:@[self.testCalendar]];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startOfYear endDate:endOfYear calendars:@[self.testCalendar]];
    NSArray* storeEvents = [[self.eventStore eventsMatchingPredicate:eventsPredicate] sortedArrayUsingSelector:@selector(compareStartAndEndDateWithEvent:)];
    
    XCTAssertEqualObjects(cacheEvents, storeEvents, @"Event cache should return the same events as the event store");
}

- (void)testCacheReturnsSameEventsAsEventStoreWhenEventSpansMultipleDaysOutsideOfDateRange
{
    // test calendar contains a multiple day event that starts in the day of
    // test start date and continues into the next day
    NSDate* startOfDay = [self.tunit beginningOfDay:self.testStartDate];
    NSDate* endOfDay = [self.tunit endOfDay:self.testStartDate];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:startOfDay to:endOfDay in:@[self.testCalendar]];
    
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startOfDay endDate:endOfDay calendars:@[self.testCalendar]];
    NSArray* storeEvents = [self.eventStore eventsMatchingPredicate:eventsPredicate];
    
    XCTAssertEqualObjects(cacheEvents, storeEvents, @"Event cache should return the same events as the event store");
    
}

- (void)testCacheReturnsSameEventsAsEventStoreForDatePrecedingPreviousDateRange
{
    NSDate* startOfMonth = [self.tunit beginningOfMonth:self.testStartDate];
    NSDate* endOfMonth = [self.tunit endOfMonth:self.testStartDate];
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
    NSDate* startOfMonth = [self.tunit beginningOfMonth:self.testStartDate];
    NSDate* endOfMonth = [self.tunit endOfMonth:self.testStartDate];
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
    NSDate* startOfMonth = [self.tunit beginningOfMonth:self.testStartDate];
    NSDate* endOfMonth = [self.tunit endOfMonth:self.testStartDate];
    NSDate* startOfTwoMonthsAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-2 toDate:startOfMonth options:0];
    NSDate* endOfTwoMonthsAgo = [self.tunit endOfMonth:startOfTwoMonthsAgo];
    
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
    NSDate* startOfMonth = [self.tunit beginningOfMonth:self.testStartDate];
    NSDate* endOfMonth = [self.tunit endOfMonth:self.testStartDate];
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
    NSDate* startOfMonth = [self.tunit beginningOfMonth:self.testStartDate];
    NSDate* endOfMonth = [self.tunit endOfMonth:self.testStartDate];
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
    NSDate* startOfMonth = [self.tunit beginningOfMonth:self.testStartDate];
    NSDate* endOfMonth = [self.tunit endOfMonth:self.testStartDate];
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
    NSDate* startOfMonth = [self.tunit beginningOfMonth:self.testStartDate];
    NSDate* endOfMonth = [self.tunit endOfMonth:self.testStartDate];
    NSDate* startOfNextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:2 toDate:endOfMonth options:0];
    NSDate* endOfNextMonth = [self.tunit endOfMonth:startOfNextMonth];
    
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
    NSDate* startOfMonth = [self.tunit beginningOfMonth:self.testStartDate];
    NSDate* endOfMonth = [self.tunit endOfMonth:self.testStartDate];
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
    NSDate* startOfYear = [self.tunit beginningOfYear:self.testStartDate];
    NSDate* endOfYear = [self.tunit endOfYear:self.testStartDate];
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

- (void)testCacheReturnsCorrectEventsAfterInvalidation
{
    // Ensure that cache loads events
    NSDate* startOfYear = [self.tunit beginningOfYear:self.testStartDate];
    NSDate* endOfYear = [self.tunit endOfYear:self.testStartDate];
    [self.eventCache eventsFrom:startOfYear to:endOfYear in:nil];
    
    // Ensure data source method returns nil
    [self.eventCache invalidateCache];
    
    NSArray* cacheEvents = [self.eventCache eventsFrom:startOfYear to:endOfYear in:nil];
    NSArray* storeEvents = [self.eventStore eventsMatchingPredicate:[self.eventStore predicateForEventsWithStartDate:startOfYear endDate:endOfYear calendars:nil]];
    
    XCTAssertEqualObjects(cacheEvents, storeEvents, @"Cache should return same events as event store after being invalidated");
}

@end
