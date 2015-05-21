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

@end

@implementation ECEventStoreProxyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.eventStore = [[EKEventStore alloc] init];
    self.eventStoreProxy = [[ECEventStoreProxy alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    self.eventStore = nil;
    self.eventStoreProxy = nil;
}

- (void)testCalendarAccess
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

- (void)testCalendars
{
    // Test calendars are equal
    NSArray* proxyCalendars = self.eventStoreProxy.calendars;
    NSArray* eventKitCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    XCTAssertTrue([proxyCalendars hasSameElements:eventKitCalendars]);
    
    // Test using calendar identifiers
    for (EKCalendar* calendar in eventKitCalendars) {
        XCTAssertTrue([[self.eventStoreProxy calendarWithIdentifier:calendar.calendarIdentifier] isEqual:[self.eventStore calendarWithIdentifier:calendar.calendarIdentifier]]);
    }
}

- (void)compareEventsFromStore:(EKEventStore*)store proxy:(ECEventStoreProxy*)proxy query:(ECTestsEventQuery*)query
{
    NSPredicate* predicate = [store predicateForEventsWithStartDate:query.startDate endDate:query.endDate calendars:query.calendars];
    NSArray* proxyEvents = [proxy eventsFrom:query.startDate to:query.endDate in:query.calendars];
    NSArray* storeEvents = [store eventsMatchingPredicate:predicate];
    
    XCTAssertTrue([NSArray eventsArray:proxyEvents isSameAsArray:storeEvents]);
}

- (void)testFetchingEvents
{
    NSDate* now = [NSDate date];
    ECTestsEventQuery* todayQuery = [[ECTestsEventQuery alloc] initWithStartDate:now type:ECTestsEventQueryTypeDay calendars:nil];
    ECTestsEventQuery* thisWeekQuery = [[ECTestsEventQuery alloc] initWithStartDate:now type:ECTestsEventQueryTypeWeek calendars:nil];
    ECTestsEventQuery* thisMonthQuery = [[ECTestsEventQuery alloc] initWithStartDate:now type:ECTestsEventQueryTypeMonth calendars:nil];
    ECTestsEventQuery* thisYearQuery = [[ECTestsEventQuery alloc] initWithStartDate:now type:ECTestsEventQueryTypeYear calendars:nil];
    NSArray* queries = @[todayQuery, thisWeekQuery, thisMonthQuery, thisYearQuery];
    
    // Fetching events within a given time range (all calendars)
    [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:todayQuery];
    [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:thisWeekQuery];
    [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:thisMonthQuery];
    [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:thisYearQuery];
    
    // Fetching events in a given calendar
    for (ECTestsEventQuery* query in queries) {
        for (EKCalendar* calendar in [self.eventStore calendarsForEntityType:EKEntityTypeEvent]) {
            query.calendars = @[calendar];
            [self compareEventsFromStore:self.eventStore proxy:self.eventStoreProxy query:query];
            query.calendars = nil; // restore test state
        }
    }
    
    // Fetching events with invalid start and end dates
    XCTAssertNil([self.eventStoreProxy eventsFrom:todayQuery.startDate to:todayQuery.endDate]);
    XCTAssertNil([self.eventStoreProxy eventsFrom:todayQuery.endDate to:todayQuery.startDate], @"End date prior to start date should return nil");
    XCTAssertNil([self.eventStoreProxy eventsFrom:todayQuery.startDate to:nil], @"No end date should return nil");
    XCTAssertNil([self.eventStoreProxy eventsFrom:nil to:todayQuery.endDate], @"No start date should return nil");
    XCTAssertNil([self.eventStoreProxy eventsFrom:nil to:nil], @"No dates should return nil");
}


- (void)testEventCreationAndSynchronization
{
    #warning Remember to erase test events
    // Test creating single event
    EKEvent* event = [self.eventStoreProxy createEvent];
    
    XCTAssertNotNil(event);
    XCTAssertNil(event.title);
    XCTAssertNil(event.startDate);
    XCTAssertNil(event.endDate);
    XCTAssertEqual(event.calendar, self.eventStore.defaultCalendarForNewEvents);
    
    
    // Test saving events
    //  - Valid data * Multiple span rules
    //  - Multiple updates * Multiple span rules
    //  - Invalid data * Multiple span rules
    //      - Nil event
    //      - No title
    //      - No start date
    //      - No end date
    //      - End date prior to start date
    //      - No calendar
    //      - Not created in proxy's event store
    event.title = @"First Event Title";
    event.location = @"123 Fake Street";
    event.startDate = [[NSDate date] beginningOfHour];
    event.endDate = [event.startDate endOfHour];
    
    NSString* identifier = event.eventIdentifier;
    
    [self.eventStoreProxy saveEvent:event span:EKSpanThisEvent];
    NSArray* events = [self.eventStoreProxy eventsFrom:[event.startDate beginningOfDay] to:[event.endDate endOfDay]];
    
    XCTAssertNotNil(events);
    XCTAssertNotNil([events eventWithIdentifier:identifier]);
    
    // Test removing events
    //  - Valid removal * Multiple span rules
    //  - Invalid removal * Multiple span rules
    //      - Remove nil
    //      - Remove fake event
    //      - Remove event twice
    

}

@end
