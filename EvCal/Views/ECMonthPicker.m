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

- (NSDate*)selectedDate
{
    if (!_selectedDate) {
        _selectedDate = [[NSDate date] beginningOfDay];
    }
    
    return _selectedDate;
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
    NSDate* firstMonthDisplayDate = [self getDisplayDateOfFirstMonth];
    
    for (NSInteger i = 0; i < kMonthViewPageCount; i++) {
        
        NSDate* firstMonthViewDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:(2 * i - 2) toDate:firstMonthDisplayDate options:0];
        ECMonthView* firstMonthView = [[ECMonthView alloc] initWithDate:firstMonthViewDate];

        NSDate* secondMonthViewDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:(2 * i - 1) toDate:firstMonthDisplayDate options:0];
        ECMonthView* secondMonthView = [[ECMonthView alloc] initWithDate:secondMonthViewDate];
        
        UIView* monthViewPage = self.monthViewPages[i];
        [monthViewPage addSubview:firstMonthView];
        [monthViewPage addSubview:secondMonthView];
        
        [monthViews addObject:firstMonthView];
        [monthViews addObject:secondMonthView];
    }
    
    return monthViews;
}

- (NSDate*)getDisplayDateOfFirstMonth
{
    NSInteger monthComponent = [self.calendar component:NSCalendarUnitMonth fromDate:self.selectedDate];
    
    if (monthComponent % 2 != 0) {
        return [self.selectedDate beginningOfMonth];
    } else {
        return [[self.calendar dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:self.selectedDate options:0] beginningOfMonth];
    }
}


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

static const NSInteger kTopMonthViewPageIndex =     0;
static const NSInteger kCenterMonthViewPageIndex =  1;
static const NSInteger kBottomMonthViewPageIndex =  2;

// This method assumes that the date of the page in the center page index should
// be used to determine the values of the other pages. The center page date MUST
// be updated and correct prior to this method's invocation.
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if ([scrollView isEqual:self.dayViewHorizontalScrollView]) {
//        
//        ECSingleDayView* visibleDayView = [self getVisibleDayView];
//        NSComparisonResult dateComparison = [visibleDayView.date compare:self.displayDate];
//        
//        switch (dateComparison) {
//            case NSOrderedDescending:
//                [self swapSingleDayViewAtIndex:kLeftDayViewIndex toIndex:kRightDayViewIndex withCenterDate:visibleDayView.date];
//                
//                [self resetSingleDayViewsLayout];
//                
//                self.displayDate = visibleDayView.date;
//                [self updateSingleDayViewsForDate:self.displayDate];
//                break;
//                
//            case NSOrderedAscending:
//                [self swapSingleDayViewAtIndex:kRightDayViewIndex toIndex:kLeftDayViewIndex withCenterDate:visibleDayView.date];
//                
//                [self resetSingleDayViewsLayout];
//                
//                self.displayDate = visibleDayView.date;
//                [self updateSingleDayViewsForDate:self.displayDate];
//                break;
//                
//            case NSOrderedSame:
//                break;
//        }
//    }
//}
//

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    
}
//- (void)resetSingleDayViewsLayout
//{
//    // recenter scroll view content offset
//    self.dayViewHorizontalScrollView.contentOffset = CGPointMake(self.dayViewHorizontalScrollView.bounds.size.width, 0);
//    // move single day screens into new positions
//    [self layoutSingleDayViews];
//}
//
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
//- (ECSingleDayView*)getVisibleDayView
//{
//    CGFloat horizontalOffset = self.dayViewHorizontalScrollView.bounds.origin.x;
//    
//    if (horizontalOffset < self.dayViewHorizontalScrollView.bounds.size.width) {
//        return self.leftDayView;
//    } else if (horizontalOffset >= self.dayViewHorizontalScrollView.bounds.size.width * 2) {
//        return self.rightDayView;
//    } else {
//        return self.centerDayView;
//    }
//}
//
//// The center date is the new center date after the page is swapped
//- (void)swapSingleDayViewAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex withCenterDate:(NSDate*)date
//{
//    ECSingleDayView* swappedSingleDayView = self.singleDayViews[oldIndex];
//    
//    [self.singleDayViews removeObjectAtIndex:oldIndex];
//    [self.singleDayViews insertObject:swappedSingleDayView atIndex:newIndex];
//}

@end
