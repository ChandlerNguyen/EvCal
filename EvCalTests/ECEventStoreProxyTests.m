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

@interface ECEventStoreProxyTests : XCTestCase

@property (nonatomic, strong) EKEventStore* eventStore;

@end

@implementation ECEventStoreProxyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.eventStore = [[EKEventStore alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    self.eventStore = nil;
}

- (void)testCalendarAccess
{
    
}

- (void)testFetchingEvents
{
    
}
@end
