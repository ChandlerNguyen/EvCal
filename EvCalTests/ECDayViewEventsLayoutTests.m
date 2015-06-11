//
//  ECDayViewEventsLayoutTests.m
//  EvCal
//
//  Created by Tom on 6/11/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
#import <XCTest/XCTest.h>

// Helpers

// EvCal Classes
#import "ECDayViewEventsLayout.h"

@interface ECDayViewEventsLayoutTests : XCTestCase

@property (nonatomic, strong) ECDayViewEventsLayout* layout;

@end

@implementation ECDayViewEventsLayoutTests

#pragma mark - Setup & Teardown

- (void)setUp {
    [super setUp];
    
    self.layout = [[ECDayViewEventsLayout alloc] init];
}

- (void)tearDown {

    
    
    [super tearDown];
}


#pragma mark - Tests

@end
