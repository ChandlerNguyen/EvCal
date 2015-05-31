//
//  ECEventStoreProxyTests.m
//  
//
//  Created by Tom on 5/19/15.
//
//

// iOS Frameworks
@import EventKit;
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// Pods
#import <JPSimulatorHacks/JPSimulatorHacks.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel __unused = DDLogLevelDebug; // Used by CocoaLumberjack

// Categories
#import "NSDate+CupertinoYankee.h"
#import "NSArray+ECTesting.h"

// EvCalTests Classes
#import "ECEventStoreProxy.h"
#import "ECTestsEventQuery.h"

@interface ECEventStoreProxyTests : XCTestCase

@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) ECEventStoreProxy* eventStoreProxy;

@property (nonatomic, strong) EKCalendar* testCalendar;

@property (nonatomic, strong) NSDate* testStartDate;

@end

@implementation ECEventStoreProxyTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
    self.testStartDate = [NSDate date];

    self.eventStore = [[EKEventStore alloc] init];
    self.eventStoreProxy = [[ECEventStoreProxy alloc] init];
    
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
    
    self.testStartDate = nil;
    self.eventStore = nil;
    self.eventStoreProxy = nil;
}

#pragma mark - Tests

#pragma mark Testing Access
- (void)testCalendarAccessAuthorizationStatusMatchesApplicationsStatus
{
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
        case (EKAuthorizationStatusNotDetermined):
            XCTAssertEqual(self.eventStoreProxy.authorizationStatus, ECAuthorizationStatusNotDetermined);
            break;
            
        case (EKAuthorizationStatusAuthorized):
            XCTAssertEqual(self.eventStoreProxy.authorizationStatus, ECAuthorizationStatusAuthorized);
            break;
            
        case (EKAuthorizationStatusDenied):
        case (EKAuthorizationStatusRestricted):
            XCTAssertEqual(self.eventStoreProxy.authorizationStatus, ECAuthorizationStatusDenied);
            break;
    }
}

#pragma mark - Testing Calendars
- (void)testProxysCalendarListIsSameAsEKEventStores
{
    // Test calendars are equal
    NSArray* proxyCalendars = self.eventStoreProxy.calendars;
    NSArray* eventKitCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    XCTAssertTrue([proxyCalendars hasSameElements:eventKitCalendars]);
}


#pragma mark Testing Event Fetching

- (void)compareEventsFromStore:(EKEventStore*)store proxy:(ECEventStoreProxy*)proxy query:(ECTestsEventQuery*)query
{
    NSPredicate* predicate = [store predicateForEventsWithStartDate:query.startDate endDate:query.endDate calendars:query.calendars];
    NSArray* proxyEvents = [proxy eventsFrom:query.startDate to:query.endDate in:query.calendars];
    NSArray* storeEvents = [store eventsMatchingPredicate:predicate];
    
    XCTAssertTrue([NSArray eventsArray:proxyEvents isSameAsArray:storeEvents]);
}

- (void)testFetchingEventsForOneDay
{
    ECTestsEventQuery* todayQuery = [[ECTestsEventQuery alloc] initWithStartDate:self.testStartDate type:ECTestsEventQueryTypeDay calendars:nil];

    [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:todayQuery];
}

- (void)testFetchingEventsForOneWeek
{
    ECTestsEventQuery* thisWeekQuery = [[ECTestsEventQuery alloc] initWithStartDate:self.testStartDate type:ECTestsEventQueryTypeWeek calendars:nil];
    
    [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:thisWeekQuery];
}

- (void)testFetchingEventsForOneMonth
{
    ECTestsEventQuery* thisMonthQuery = [[ECTestsEventQuery alloc] initWithStartDate:self.testStartDate type:ECTestsEventQueryTypeMonth calendars:nil];

    [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:thisMonthQuery];
}

- (void)testFetchingEventsForOneYear
{
    ECTestsEventQuery* thisYearQuery = [[ECTestsEventQuery alloc] initWithStartDate:self.testStartDate type:ECTestsEventQueryTypeYear calendars:nil];

    [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:thisYearQuery];
}

- (void)testFetchingEventsInAGivenCalendar
{
    ECTestsEventQuery* thisYearQuery = [[ECTestsEventQuery alloc] initWithStartDate:self.testStartDate type:ECTestsEventQueryTypeYear calendars:nil];
    
    for (EKCalendar* calendar in [self.eventStore calendarsForEntityType:EKEntityTypeEvent]) {
        thisYearQuery.calendars = @[calendar];
        [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:thisYearQuery];
        thisYearQuery.calendars = nil; // restore test state
    }
}

- (void)testFetchingEventsWithStartDateAndEndDateSwappedReturnsNil
{
    ECTestsEventQuery* todayQuery = [[ECTestsEventQuery alloc] initWithStartDate:self.testStartDate type:ECTestsEventQueryTypeDay calendars:nil];
    
    XCTAssertNil([self.eventStoreProxy eventsFrom:todayQuery.endDate to:todayQuery.startDate], @"End date prior to start date should return nil");
}

- (void)testFetchingEventsWithNilEndDateReturnsNil
{
    ECTestsEventQuery* todayQuery = [[ECTestsEventQuery alloc] initWithStartDate:self.testStartDate type:ECTestsEventQueryTypeDay calendars:nil];
    
    XCTAssertNil([self.eventStoreProxy eventsFrom:todayQuery.startDate to:nil], @"No end date should return nil");
}

- (void)testFetchingEventsWithNilStartDateReturnsNil
{
    ECTestsEventQuery* todayQuery = [[ECTestsEventQuery alloc] initWithStartDate:self.testStartDate type:ECTestsEventQueryTypeDay calendars:nil];
    
    XCTAssertNil([self.eventStoreProxy eventsFrom:nil to:todayQuery.endDate], @"No start date should return nil");
}


#pragma mark Testing Event Creation

- (void)testCreatingEventReturnsNonNilEvent
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    XCTAssertNotNil(singleEvent);
}

- (void)testNewlyCreatedEventHasNilTitle
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];

    XCTAssertNil(singleEvent.title);
}

- (void)testNewlyCreatedEventHasNilStartDate
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];

    XCTAssertNil(singleEvent.startDate);

}

- (void)testNewlyCreatedEventHasNilEndDate
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];

    XCTAssertNil(singleEvent.endDate);
}

- (void)testNewlyCreatedEventHasDefaultCalendarForNewEvents
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];

    XCTAssertTrue([singleEvent.calendar isEqual:self.eventStore.defaultCalendarForNewEvents]);
}


#pragma mark Testing Saving Events

- (void)testSavingEventReturnsYesOnSuccess
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];

    singleEvent.title = @"First Event Title";
    singleEvent.location = @"123 Fake Street";
    singleEvent.startDate = self.testStartDate;
    singleEvent.endDate = [singleEvent.startDate endOfHour];
    singleEvent.calendar = self.testCalendar;

    XCTAssert([self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent]);
    
    [self.eventStore removeEvent:singleEvent span:EKSpanThisEvent commit:YES error:nil];
}

- (void)testSavedEventCanBeFetched
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    singleEvent.title = @"First Event Title";
    singleEvent.location = @"123 Fake Street";
    singleEvent.startDate = self.testStartDate;
    singleEvent.endDate = [singleEvent.startDate endOfHour];
    singleEvent.calendar = self.testCalendar;

    [self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent];
    NSArray* events = [self.eventStoreProxy eventsFrom:[singleEvent.startDate beginningOfDay] to:[singleEvent.endDate endOfDay] in:@[self.testCalendar]];
    NSString* singleEventID = singleEvent.eventIdentifier;
    
    XCTAssertNotNil([events eventWithIdentifier:singleEventID]);
    
    [self.eventStore removeEvent:singleEvent span:EKSpanThisEvent commit:YES error:nil];
}

- (void)testSavingRecurrinvEventCreatesMultipleEvents
{
    EKEvent* recurringEvent = [self.eventStoreProxy createEvent];
    recurringEvent.title = @"Recurring Event Title";
    recurringEvent.location = @"123 Fake Street";
    recurringEvent.startDate = self.testStartDate;
    recurringEvent.endDate = [recurringEvent.startDate endOfHour];
    recurringEvent.calendar = self.testCalendar;
    EKRecurrenceRule* weeklyRecurrence = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                                                                      interval:1
                                                                                           end:[EKRecurrenceEnd recurrenceEndWithOccurrenceCount:50]];
    [recurringEvent addRecurrenceRule:weeklyRecurrence];
    [self.eventStoreProxy saveEvent:recurringEvent span:EKSpanFutureEvents];
    
    XCTAssert([self.eventStoreProxy eventsFrom:[self.testStartDate beginningOfDay] to:[[[self.testStartDate endOfYear]tomorrow] endOfYear] in:@[self.testCalendar]].count == 50);
    
    [self.eventStore removeEvent:recurringEvent span:EKSpanFutureEvents commit:YES error:nil];
}

#pragma mark Testing Removing Events

- (void)testRemovingEventReturnsYesOnSuccess
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    singleEvent.title = @"First Event Title";
    singleEvent.location = @"123 Fake Street";
    singleEvent.startDate = self.testStartDate;
    singleEvent.endDate = [singleEvent.startDate endOfHour];
    singleEvent.calendar = self.testCalendar;
    
    [self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent];
    XCTAssert([self.eventStoreProxy removeEvent:singleEvent span:EKSpanThisEvent]);
}

- (void)testRemovingEventTwiceIsUnsuccessful
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    singleEvent.title = @"First Event Title";
    singleEvent.location = @"123 Fake Street";
    singleEvent.startDate = self.testStartDate;
    singleEvent.endDate = [singleEvent.startDate endOfHour];
    singleEvent.calendar = self.testCalendar;
    
    [self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent];
    [self.eventStoreProxy removeEvent:singleEvent span:EKSpanThisEvent];
    XCTAssertFalse([self.eventStoreProxy removeEvent:singleEvent span:EKSpanThisEvent]);
}

- (void)testRemovedEventsAreNoLongerFetched
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    singleEvent.title = @"First Event Title";
    singleEvent.location = @"123 Fake Street";
    singleEvent.startDate = self.testStartDate;
    singleEvent.endDate = [singleEvent.startDate endOfHour];
    singleEvent.calendar = self.testCalendar;

    [self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent];
    [self.eventStoreProxy removeEvent:singleEvent span:EKSpanThisEvent];
    NSArray* events = [self.eventStoreProxy eventsFrom:[singleEvent.startDate beginningOfDay] to:[singleEvent.endDate endOfDay] in:@[self.testCalendar]];
    XCTAssertNil(events);
}

- (void)testAllInstancesOfARecurringEventAreRemoved
{
    EKEvent* recurringEvent = [self.eventStoreProxy createEvent];
    recurringEvent.title = @"Recurring Event Title";
    recurringEvent.location = @"123 Fake Street";
    recurringEvent.startDate = self.testStartDate;
    recurringEvent.endDate = [recurringEvent.startDate endOfHour];
    recurringEvent.calendar = self.testCalendar;
    EKRecurrenceRule* weeklyRecurrence = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                                                                      interval:1
                                                                                           end:[EKRecurrenceEnd recurrenceEndWithOccurrenceCount:50]];
    [recurringEvent addRecurrenceRule:weeklyRecurrence];
    [self.eventStoreProxy saveEvent:recurringEvent span:EKSpanFutureEvents];
    [self.eventStoreProxy removeEvent:recurringEvent span:EKSpanFutureEvents];
    
    XCTAssert([self.eventStoreProxy eventsFrom:[self.testStartDate beginningOfDay] to:[[[self.testStartDate endOfYear]tomorrow] endOfYear] in:@[self.testCalendar]].count == 0);
}

- (void)testSavingNilEventFails
{
    XCTAssertFalse([self.eventStoreProxy saveEvent:nil span:EKSpanThisEvent]); // save nil
}

- (void)testSavingEventWithNoStartDateFails
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    singleEvent.title = @"Single Event Title";
    singleEvent.endDate = self.testStartDate;
    singleEvent.calendar = self.testCalendar;
    
    XCTAssertFalse([self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent]); // no start date
}

- (void)testSavingEventWithNoEndDateFails
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    singleEvent.title = @"Single Event Title";
    singleEvent.startDate = self.testStartDate;
    singleEvent.calendar = self.testCalendar;
    
    XCTAssertFalse([self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent]); // no end date
}

- (void)testSavingEventWithEndDatePriorToStartDateFails
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    singleEvent.title = @"Single Event Title";
    singleEvent.endDate = self.testStartDate;
    singleEvent.startDate = [self.testStartDate endOfHour];
    singleEvent.calendar = self.testCalendar;
    
    XCTAssertFalse([self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent]); // end date prior to start date
}

- (void)testSavingEventWithNoCalendarFails
{
    EKEvent* singleEvent = [self.eventStoreProxy createEvent];
    
    singleEvent.title = @"Single Event Title";
    singleEvent.startDate = self.testStartDate;
    singleEvent.endDate = [self.testStartDate endOfHour];
    
    singleEvent.calendar = nil;
    XCTAssertFalse([self.eventStoreProxy saveEvent:singleEvent span:EKSpanThisEvent]); // no end date
}

@end
