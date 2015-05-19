//
//  ECEventStoreProxyTests.m
//  
//
//  Created by Tom on 5/19/15.
//
//

@import EventKit;
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <JPSimulatorHacks/JPSimulatorHacks.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel __unused = DDLogLevelDebug; // Used by CocoaLumberjack
#import "NSDate+CupertinoYankee.h"
#import "NSArray+ECTesting.h"

#import "ECEventStoreProxy.h"

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
    
    // Test default calendar
    XCTAssertTrue([self.eventStoreProxy.defaultCalendarForNewEvents isEqual:self.eventStore.defaultCalendarForNewEvents]);
    
    // Test using calendar identifiers
    for (EKCalendar* calendar in eventKitCalendars) {
        XCTAssertTrue([[self.eventStoreProxy calendarWithIdentifier:calendar.calendarIdentifier] isEqual:[self.eventStore calendarWithIdentifier:calendar.calendarIdentifier]]);
    }
}



- (void)testFetchingEvents
{
    NSDate* today = [NSDate date];
    NSDate* beginningOfToday = [today beginningOfDay];
    NSDate* endOfToday = [today endOfDay];
    // Fetching today's events (all calendars)
    NSPredicate* todayPredicate = [self.eventStore predicateForEventsWithStartDate:beginningOfToday endDate:endOfToday calendars:nil];
    XCTAssertTrue([[self.eventStoreProxy eventsFrom:beginningOfToday to:endOfToday] hasSameElements:[self.eventStore eventsMatchingPredicate:todayPredicate]]);
    
    // Fetching today's events in a given calendar
    for (EKCalendar* calendar in [self.eventStore calendarsForEntityType:EKEntityTypeEvent]) {
        NSPredicate* pred = [self.eventStore predicateForEventsWithStartDate:beginningOfToday endDate:endOfToday calendars:@[calendar]];
        NSArray* proxyEvents = [self.eventStoreProxy eventsFrom:beginningOfToday to:endOfToday in:@[calendar]];
        NSArray* storeEvents = [self.eventStore eventsMatchingPredicate:pred];
        
        // EKEventStore returns nil if no events could be found in the given time span.
        // Since the proxy attempts to remain true to EKEventStore's behavior it will
        // also return nil.
        if (!storeEvents) {
            XCTAssertNil(proxyEvents);
        } else {
            XCTAssertTrue([proxyEvents hasSameElements:storeEvents]);
        }
    }

    
    // Fetching this year's events
    NSDate* beginningOfYear = [today beginningOfYear];
    NSDate* endOfYear = [today endOfYear];
    
    NSPredicate* thisYearPredicate = [self.eventStore predicateForEventsWithStartDate:beginningOfYear endDate:endOfYear calendars:nil];
    XCTAssertTrue([[self.eventStoreProxy eventsFrom:beginningOfYear to:endOfYear] hasSameElements:[self.eventStore eventsMatchingPredicate:thisYearPredicate]]);
    
    for (EKCalendar* calendar in [self.eventStore calendarsForEntityType:EKEntityTypeEvent]) {
        NSPredicate* pred = [self.eventStore predicateForEventsWithStartDate:beginningOfYear endDate:endOfYear calendars:@[calendar]];
        XCTAssertTrue([[self.eventStoreProxy eventsFrom:beginningOfYear to:endOfYear in:@[calendar]] hasSameElements:[self.eventStore eventsMatchingPredicate:pred]]);
    }
    
    XCTAssertTrue([[self.eventStoreProxy eventsFrom:beginningOfYear to:endOfYear] hasSameElements:[self.eventStoreProxy eventsFrom:beginningOfYear to:endOfYear in:nil]]);
    
    // Fetching events with invalid start and end dates
    XCTAssertNil([self.eventStoreProxy eventsFrom:beginningOfToday to:beginningOfToday]);
    XCTAssertNil([self.eventStoreProxy eventsFrom:endOfToday to:beginningOfToday], @"End date prior to start date should return nil");
    XCTAssertNil([self.eventStoreProxy eventsFrom:beginningOfToday to:nil], @"No end date should return nil");
    XCTAssertNil([self.eventStoreProxy eventsFrom:nil to:endOfToday], @"No start date should return nil");
    XCTAssertNil([self.eventStoreProxy eventsFrom:nil to:nil], @"No dates should return nil");
}


- (void)testEventCreationAndSynchronization
{
    
}

@end
