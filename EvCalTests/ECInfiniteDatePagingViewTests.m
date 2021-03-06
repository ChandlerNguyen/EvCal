//
//  ECInfiniteDatePagingViewTests.m
//  EvCal
//
//  Created by Tom on 6/23/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// Frameworks
#import <XCTest/XCTest.h>

// EvCal Classes
#import "ECInfiniteDatePagingView.h"
#import "ECTestsDateView.h"

@interface ECInfiniteDatePagingViewTests : XCTestCase <ECInfiniteDatePagingViewDataSource, ECInfiniteDatePagingViewDelegate>

@property (nonatomic, strong) NSDate* testStartDate;
@property (nonatomic, strong) ECInfiniteDatePagingView* infiniteDatePagingView;

@property (nonatomic) BOOL dateChangedCalled;
@property (nonatomic) BOOL pageViewRequested;
@property (nonatomic) BOOL preparePageRequested;

@end

@implementation ECInfiniteDatePagingViewTests

# pragma mark - Setup & Tear down

- (void)setUp {
    [super setUp];
   
    self.testStartDate = [NSDate date];
    self.infiniteDatePagingView = [[ECInfiniteDatePagingView alloc] initWithFrame:CGRectZero date:self.testStartDate];
    self.infiniteDatePagingView.pageViewDelegate = self;
    self.infiniteDatePagingView.pageViewDataSource = self;
    
    self.dateChangedCalled = NO;
    self.pageViewRequested = NO;
    self.preparePageRequested = NO;
}

- (void)tearDown {
    self.testStartDate = nil;
    self.infiniteDatePagingView = nil;
    
    [super tearDown];
}

#pragma mark - ECInfiniteDatePagingView data source and delegate
// delegate
- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv dateChangedFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    self.dateChangedCalled = YES;
}
// data source
- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv preparePage:(ECDatePage*)page
{
    self.preparePageRequested = YES;
}

- (UIView*)pageViewForInfiniteDateView:(ECInfiniteDatePagingView *)idv
{
    self.pageViewRequested = YES;
    return [[ECTestsDateView alloc] initWithFrame:CGRectZero];
}


- (void)testInfiniteDatePagingViewIsCreated
{
    XCTAssertNotNil(self.infiniteDatePagingView);
}

- (void)testInfiniteDatePagingViewHasCorrectFrame
{
    XCTAssertTrue(CGRectEqualToRect(self.infiniteDatePagingView.frame, CGRectZero));
}

- (void)testInfiniteDatePagingViewHasCorrectDate
{
    XCTAssertEqualObjects(self.infiniteDatePagingView.date, self.testStartDate);
}

- (void)testInfiniteDatePagingViewHasCorrectDefaultCalendarUnit
{
    XCTAssertEqual(self.infiniteDatePagingView.calendarUnit, NSCalendarUnitDay);
}

- (void)testInfiniteDatePagingViewHasCorrectDefaultPageDateDelta
{
    XCTAssertEqual(self.infiniteDatePagingView.pageDateDelta, 1);
}

- (void)testInfiniteDatePagingViewHasVisiblePage
{
    XCTAssertNotNil(self.infiniteDatePagingView.visiblePage);
}

- (void)testInfiniteDatePagingViewVisiblePageIsKindOfECTestsDateView
{
    XCTAssertTrue([self.infiniteDatePagingView.visiblePage isKindOfClass:[ECTestsDateView class]]);
}

- (void)testInfiniteDatePagingViewVisiblePageHasCorrectDate
{
    ECTestsDateView* dateView = (ECTestsDateView*)self.infiniteDatePagingView.visiblePage;
    
    XCTAssertTrue([[NSCalendar currentCalendar] isDate:dateView.date inSameDayAsDate:self.testStartDate]);
}

- (void)testInfiniteDatePagingViewRequestsPreparingPagesAfterRefresh
{
    self.preparePageRequested = NO;
    [self.infiniteDatePagingView refreshPages];
    
    XCTAssertTrue(self.preparePageRequested);
}

- (void)testInfiniteDatePagingViewHasCorrectDateAfterRefresh
{
    [self.infiniteDatePagingView refreshPages];
    
    XCTAssertTrue([[NSCalendar currentCalendar] isDate:self.testStartDate inSameDayAsDate:self.infiniteDatePagingView.date]);
}

- (void)testInfiniteDatePagingViewVisiblePageHasCorrectDateAfterRefresh
{
    [self.infiniteDatePagingView refreshPages];
    
    ECTestsDateView* dateView = (ECTestsDateView*)self.infiniteDatePagingView.visiblePage;
    XCTAssertTrue([[NSCalendar currentCalendar] isDate:self.testStartDate inSameDayAsDate:dateView.date]);
}

- (void)testInfiniteDatePagingViewCallsDelegateOnScroll
{
    self.dateChangedCalled = NO;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* nextWeekDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:self.testStartDate options:0];
    [self.infiniteDatePagingView scrollToDate:nextWeekDate animated:NO];
    
    XCTAssertTrue(self.dateChangedCalled);
}

- (void)testInfiniteDatePagingViewHasCorrectDateAfterScroll
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* nextWeekDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:self.testStartDate options:0];
    [self.infiniteDatePagingView scrollToDate:nextWeekDate animated:NO];
    
    XCTAssertTrue([calendar isDate:nextWeekDate inSameDayAsDate:self.infiniteDatePagingView.date]);
}

- (void)testInfiniteDatePagingViewUpdatesVisiblePageAfterScrollingToDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* nextWeekDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:self.testStartDate options:0];
    [self.infiniteDatePagingView scrollToDate:nextWeekDate animated:NO];
    
    XCTAssertTrue([calendar isDate:nextWeekDate inSameDayAsDate:self.infiniteDatePagingView.date]);
}
@end
