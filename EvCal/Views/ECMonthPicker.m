//
//  ECMonthPicker.m
//  EvCal
//
//  Created by Tom on 9/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECMonthPicker.h"
#import "ECMonthView.h"
#import "NSDate+CupertinoYankee.h"
@interface ECMonthPicker() <UIScrollViewDelegate, ECMonthViewDelegate>

@property (nonatomic, strong) NSCalendar* calendar;

@property (nonatomic, weak) UIScrollView* monthViewContainer;

@property (nonatomic, strong) NSMutableArray* monthViewPages;
@property (nonatomic, strong) NSMutableArray* monthViews;

@end

@implementation ECMonthPicker

const static NSInteger kMonthViewPageCount =    3;

- (instancetype)initWithSelectedDate:(nullable NSDate *)date
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _selectedDate = date;
    }
    
    return self;
}

- (NSDate*)firstVisibleDate
{
    if (!_firstVisibleDate) {
        NSDate* today = [[NSDate date] beginningOfMonth];
        NSInteger monthComponent = [self.calendar component:NSCalendarUnitMonth fromDate:today];
        
        if (monthComponent % 2 != 0) {
            _firstVisibleDate = [today beginningOfMonth];
        } else {
            _firstVisibleDate = [[self.calendar dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:today options:0] beginningOfMonth];
        }
    }
    
    return _firstVisibleDate;
}

- (NSCalendar*)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    
    return _calendar;
}

- (UIScrollView*)monthViewContainer
{
    if (!_monthViewContainer) {
        UIScrollView* monthViewContainer = [[UIScrollView alloc] init];
        
        monthViewContainer.showsHorizontalScrollIndicator = NO;
        monthViewContainer.showsVerticalScrollIndicator = NO;
        monthViewContainer.delegate = self;
        monthViewContainer.pagingEnabled = YES;
        
        _monthViewContainer = monthViewContainer;
        [self addSubview:monthViewContainer];
    }
    
    return _monthViewContainer;
}

- (NSMutableArray*)monthViewPages
{
    if (!_monthViewPages) {
        _monthViewPages = [self createMonthViewPages];
    }
    
    return _monthViewPages;
}

- (NSMutableArray*)createMonthViewPages
{
    NSMutableArray* monthViewPages = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 2 * kMonthViewPageCount; i += 2) {
        UIView* monthViewPage = [[UIView alloc] init];
        
        
        [self.monthViewContainer addSubview:monthViewPage];
        
        [monthViewPages addObject:monthViewPage];
    }
    
    return monthViewPages;
}

- (NSMutableArray*)monthViews
{
    if (!_monthViews) {
        _monthViews = [self createMonthViews];
    }
    
    return _monthViews;
}

- (NSMutableArray*)createMonthViews
{
    NSMutableArray* monthViews = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < kMonthViewPageCount; i++) {
        
        NSDate* firstMonthViewDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:(2 * i - 2) toDate:self.firstVisibleDate options:0];
        ECMonthView* firstMonthView = [[ECMonthView alloc] initWithDate:firstMonthViewDate];

        NSDate* secondMonthViewDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:(2 * i - 1) toDate:self.firstVisibleDate options:0];
        ECMonthView* secondMonthView = [[ECMonthView alloc] initWithDate:secondMonthViewDate];
        
        UIView* monthViewPage = self.monthViewPages[i];
        [monthViewPage addSubview:firstMonthView];
        [monthViewPage addSubview:secondMonthView];
        
        [monthViews addObject:firstMonthView];
        [monthViews addObject:secondMonthView];
    }
    
    return monthViews;
}


- (void)updateMonthViewPagesForDate:(NSDate*)date
{
    NSDate* centerPageFirstDate = date;
    NSDate* centerPageSecondDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:centerPageFirstDate options:0];
    NSDate* topPageFirstDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:-2 toDate:centerPageFirstDate options:0];
    NSDate* topPageSecondDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:topPageFirstDate options:0];
    NSDate* bottomPageFirstDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:2 toDate:centerPageFirstDate options:0];
    NSDate* bottomPageSecondDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:bottomPageFirstDate options:0];
    NSArray* dates = @[topPageFirstDate, topPageSecondDate, centerPageFirstDate, centerPageSecondDate, bottomPageFirstDate, bottomPageSecondDate];
    
    for (NSInteger i = 0; i < kMonthViewPageCount; i++) {
        NSArray* monthViews = [self.monthViews subarrayWithRange:NSMakeRange(2 * i, 2)];
        NSArray* monthViewDates = [dates subarrayWithRange:NSMakeRange(2 * i, 2)];
        
        [self updateMonthViews:monthViews forDates:monthViewDates];
    }
}

- (void)updateMonthViews:(NSArray*)monthViews forDates:(NSArray*)dates
{
    for (NSInteger i = 0; i < monthViews.count; i++) {
        ECMonthView* monthView = monthViews[i];
        NSDate* date = dates[i];
        
        [monthView updateDatesToMonthContainingDate:date];
    }
}
//- (void)updateSingleDayView:(ECSingleDayView*)singleDayView forDate:(NSDate*)date
//{
//    NSArray* events = [self.dayViewDataSource dayView:self eventsForDate:date];
//    NSArray* eventViews = [ECEventViewFactory eventViewsForEvents:events reusingViews:singleDayView.eventViews];
//    
//    singleDayView.date = date;
//    
//    [singleDayView clearEventViews];
//    [singleDayView addEventViews:eventViews];
//}

#pragma mark - Layout

static const NSInteger kPageViewNumColumns = 9;
static const NSInteger kPageViewNumRows = 19;
static const NSInteger kMonthViewNumColumns = 7;
static const NSInteger kMonthViewNumRows = 8;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutMonthViewContainer];
    [self layoutMonthViewPages];
}

- (void)layoutMonthViewContainer
{
    CGSize monthViewContainerContentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * kMonthViewPageCount);
    
    self.monthViewContainer.frame = self.bounds;
    self.monthViewContainer.contentSize = monthViewContainerContentSize;
    self.monthViewContainer.contentOffset = CGPointMake(0, self.bounds.size.height);
}

- (void)layoutMonthViewPages
{
    for (NSInteger i = 0; i < kMonthViewPageCount; i++) {
        CGRect monthViewPageFrame = CGRectMake(self.monthViewContainer.bounds.origin.x,
                                               self.monthViewContainer.bounds.size.height * i,
                                               self.monthViewContainer.bounds.size.width,
                                               self.monthViewContainer.bounds.size.height);
        
        UIView* monthViewPage = self.monthViewPages[i];
        monthViewPage.frame = monthViewPageFrame;
        
        ECMonthView* firstMonthView = self.monthViews[2 * i];
        ECMonthView* secondMonthView = self.monthViews[2 * i + 1];
        
        CGFloat colWidth = monthViewPageFrame.size.width / kPageViewNumColumns;
        CGFloat monthViewWidth = colWidth * kMonthViewNumColumns;
        
        CGFloat rowHeight = monthViewPageFrame.size.height / kPageViewNumRows;
        CGFloat monthViewHeight = rowHeight * kMonthViewNumRows;
        
        CGRect firstMonthViewFrame = CGRectMake(monthViewPage.bounds.origin.x + colWidth,
                                                monthViewPage.bounds.origin.y + rowHeight,
                                                monthViewWidth,
                                                monthViewHeight);
        
        CGRect secondMonthViewFrame = CGRectMake(monthViewPage.bounds.origin.x + colWidth,
                                                 CGRectGetMaxY(firstMonthViewFrame) + rowHeight,
                                                 monthViewWidth,
                                                 monthViewHeight);
        
        firstMonthView.frame = firstMonthViewFrame;
        secondMonthView.frame = secondMonthViewFrame;
    }
}


#pragma mark - UIScrollView Delegate

static const NSInteger kTopPageIndex =              0;
static const NSInteger kBottomPageIndex =           2;

static const NSInteger kTopPageMonthViewIndex =     0;
static const NSInteger kCenterPageMonthViewIndex =  2;
static const NSInteger kBottomPageMonthViewIndex =  4;

// This method assumes that the date of the page in the center page index should
// be used to determine the values of the other pages. The center page date MUST
// be updated and correct prior to this method's invocation.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    ECMonthView* firstVisibleMonthView = [self getFirstVisibleMonth];
    NSComparisonResult dateComparison = [firstVisibleMonthView.firstDate compare:self.firstVisibleDate];
    
    switch (dateComparison) {
        case NSOrderedDescending: // visible month view date is after previous visible date
        case NSOrderedAscending: // visible month view date is before previous visible date
            if (dateComparison == NSOrderedAscending) {
                [self swapMonthViewPageAtIndex:kBottomPageIndex toIndex:kTopPageIndex];
            } else {
                [self swapMonthViewPageAtIndex:kTopPageIndex toIndex:kBottomPageIndex];
            }
            
            [self resetMonthViewPagesLayout];
            
            self.firstVisibleDate = firstVisibleMonthView.firstDate;
            [self updateMonthViewPagesForDate:self.firstVisibleDate];
            break;
            
        case NSOrderedSame:
            break;
    }
}

- (ECMonthView*)getFirstVisibleMonth
{
    CGFloat verticalOffset = self.monthViewContainer.bounds.origin.y;
    
    if (verticalOffset < self.monthViewContainer.bounds.size.height) {
        return self.monthViews[kTopPageMonthViewIndex];
    } else if (verticalOffset >= self.monthViewContainer.bounds.size.height * 2) {
        return self.monthViews[kBottomPageMonthViewIndex];
    } else {
        return self.monthViews[kCenterPageMonthViewIndex];
    }
}

// The center date is the new center date after the page is swapped
- (void)swapMonthViewPageAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    // move month view pages
    UIView* monthViewPage = self.monthViewPages[fromIndex];
    
    [self.monthViewPages removeObject:monthViewPage];
    [self.monthViewPages insertObject:monthViewPage atIndex:toIndex];
    
    // move month views
    ECMonthView* firstMonthView = self.monthViews[fromIndex * 2];
    ECMonthView* secondMonthView = self.monthViews[fromIndex * 2 + 1];
    
    [self.monthViews removeObject:firstMonthView];
    [self.monthViews removeObject:secondMonthView];
    
    [self.monthViews insertObject:firstMonthView atIndex:toIndex * 2];
    [self.monthViews insertObject:secondMonthView atIndex:toIndex * 2 + 1];
}

- (void)resetMonthViewPagesLayout
{
    self.monthViewContainer.contentOffset = CGPointMake(0, self.monthViewContainer.bounds.size.height);
    
    [self layoutMonthViewPages];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat horizontalContentOffset = scrollView.contentOffset.x;
//    if (self.scrollingToDate && (horizontalContentOffset == 0 || horizontalContentOffset == 2 * self.dayViewHorizontalScrollView.bounds.size.width)) {
//        
//        [self swapSingleDayViewAtIndex:self.swapPageFromIndex toIndex:self.swapPageToIndex withCenterDate:self.displayDate];
//        [self resetSingleDayViewsLayout];
//        [self updateSingleDayViewsForDate:self.displayDate];
//        
//        self.scrollingToDate = NO;
//    }
//}
//
@end
