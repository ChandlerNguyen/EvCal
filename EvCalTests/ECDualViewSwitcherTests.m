//
//  ECDualViewSwitcherTests.m
//  EvCal
//
//  Created by Tom on 8/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ECDualViewSwitcher.h"

@interface ECDualViewSwitcherTests : XCTestCase

@property (nonatomic, weak) UIView* primaryView;
@property (nonatomic, weak) UIView* secondaryView;
@property (nonatomic, strong) ECDualViewSwitcher* dualViewSwitcher;

@end

@implementation ECDualViewSwitcherTests

#pragma mark - Setup and Tear down

- (void)setUp {
    [super setUp];
    
    UIView* primaryView = [[UIView alloc] init];
    UIView* secondaryView = [[UIView alloc] init];
    self.primaryView = primaryView;
    self.secondaryView = secondaryView;
    self.dualViewSwitcher = [[ECDualViewSwitcher alloc] initWithFrame:CGRectZero
                                                          primaryView:self.primaryView
                                                        secondaryView:self.secondaryView];
}

- (void)tearDown {
    self.primaryView = nil;
    self.secondaryView = nil;
    self.dualViewSwitcher = nil;
    
    [super tearDown];
}


#pragma mark - Tests

#pragma mark Initializing
- (void)testDualViewSwitcherCanBeCreated
{
    XCTAssertNotNil(self.dualViewSwitcher);
}

- (void)testDualViewSwitcherHasPrimaryView
{
    XCTAssertNotNil(self.dualViewSwitcher.primaryView);
}

- (void)testDualViewSwitcherPrimaryViewIsSameAsViewProvidedAtInitialization
{
    XCTAssertEqual(self.dualViewSwitcher.primaryView, self.primaryView);
}

- (void)testDualViewSwitcherHasSecondaryView
{
    XCTAssertNotNil(self.dualViewSwitcher.secondaryView);
}

- (void)testDualViewSwitcherSecondaryViewIsSameAsViewProvidedAtInitialization
{
    XCTAssertEqual(self.dualViewSwitcher.secondaryView, self.secondaryView);
}

- (void)testDualViewSwitcherHasVisibleView
{
    XCTAssertNotNil(self.dualViewSwitcher.visibleView);
}

- (void)testDualViewSwitcherVisibleViewIsSameAsPrimaryView
{
    XCTAssertEqual(self.dualViewSwitcher.visibleView, self.dualViewSwitcher.primaryView);
}

#pragma mark Switching
- (void)testDualViewSwitcherChangesVisibleViewToSecondaryViewAfterSwitchViewIsCalledOnce
{
    [self.dualViewSwitcher switchView:NO];
    XCTAssertEqual(self.dualViewSwitcher.visibleView, self.dualViewSwitcher.secondaryView);
}

- (void)testDualViewSwitcherChangesVisibleViewToPrimaryViewAfterSwitchViewIsCalledTwice
{
    [self.dualViewSwitcher switchView:NO];
    [self.dualViewSwitcher switchView:NO];
    XCTAssertEqual(self.dualViewSwitcher.visibleView, self.dualViewSwitcher.primaryView);
}

- (void)testDualViewSwitcherSetsVisibleViewToPrimaryViewAfterSwitchToPrimaryViewIsCalled
{
    [self.dualViewSwitcher switchToPrimaryView:NO];
    XCTAssertEqual(self.dualViewSwitcher.visibleView, self.dualViewSwitcher.primaryView);
}

- (void)testDualViewSwitcherSetsVisibleViewToSecondaryViewAfterSwitchToSecondaryViewIsCalled
{
    [self.dualViewSwitcher switchToSecondayView:NO];
    XCTAssertEqual(self.dualViewSwitcher.visibleView, self.dualViewSwitcher.secondaryView);
}

- (void)testDualViewSwitcherSetsVisibleViewToPrimaryViewIfCalledWhenSecondaryViewIsVisible
{
    [self.dualViewSwitcher switchToSecondayView:NO];
    [self.dualViewSwitcher switchToPrimaryView:NO];
    XCTAssertEqual(self.dualViewSwitcher.visibleView, self.dualViewSwitcher.primaryView);
}

- (void)testDualViewSwitcherSetsVisibleViewToSecondaryViewIfCalledWhenPrimaryViewIsVisible
{
    [self.dualViewSwitcher switchToPrimaryView:NO];
    [self.dualViewSwitcher switchToSecondayView:NO];
    XCTAssertEqual(self.dualViewSwitcher.visibleView, self.dualViewSwitcher.secondaryView);
}

@end
