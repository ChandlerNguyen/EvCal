//
//  ECRecurrenceRuleFormatterTests.m
//  EvCal
//
//  Created by Tom on 7/6/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// Frameworks
@import EventKit;
#import <XCTest/XCTest.h>

// EvCal Classes
#import "ECRecurrenceRuleFormatter.h"

@interface ECRecurrenceRuleFormatterTests : XCTestCase

@property (nonatomic, strong) ECRecurrenceRuleFormatter* recurrenceRuleFormatter;

@end

@implementation ECRecurrenceRuleFormatterTests

#pragma mark - Setup & tear down

- (void)setUp {
    [super setUp];

    self.recurrenceRuleFormatter = [[ECRecurrenceRuleFormatter alloc] init];
}

- (void)tearDown {
    
    self.recurrenceRuleFormatter = nil;
    
    [super tearDown];
}


#pragma mark - Tests

- (void)testRecurrenceRuleFormatterCanBeCreated
{
    XCTAssertNotNil(self.recurrenceRuleFormatter);
}

- (void)testRecurrenceRuleFormatterCreatesDailyRecurrenceRuleFromString
{
    
}

@end
