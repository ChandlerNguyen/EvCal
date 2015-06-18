//
//  ECDayView.m
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//



// EvCal Classes
#import "ECDayView.h"
#import "ECSingleDayView.h"
#import "ECInfiniteHorizontalDatePagingView.h"

@interface ECDayView() <UIScrollViewDelegate, ECInfiniteHorizontalDatePagingViewDataSource, ECInfiniteHorizontalDatePagingViewDelegate>

@property (nonatomic, weak) ECInfiniteHorizontalDatePagingView* dayViewContainer;

@end

@implementation ECDayView

#pragma mark - Properties and Lifecycle

- (void)setDisplayDate:(NSDate *)displayDate animated:(BOOL)animated
{
    _displayDate = displayDate;
    
    self.dayViewContainer.date = displayDate;
    
    [self refreshCalendarEvents];
}

- (ECInfiniteHorizontalDatePagingView*)dayViewContainer
{
    if (!_dayViewContainer) {
        ECSingleDayView* pageView = [[ECSingleDayView alloc] initWithFrame:CGRectZero];
        ECInfiniteHorizontalDatePagingView* dVC = [[ECInfiniteHorizontalDatePagingView alloc] initWithFrame:self.bounds
                                                                                                   pageView:pageView
                                                                                                       date:self.displayDate];
        
        _dayViewContainer = dVC;
        [self addSubview:dVC];
        
        [self setupDayViewContainer];
    }
    
    return _dayViewContainer;
}

- (void)setupDayViewContainer
{
    self.dayViewContainer.decelerationRate = UIScrollViewDecelerationRateFast;
    self.dayViewContainer.showsHorizontalScrollIndicator = NO;
    self.dayViewContainer.showsVerticalScrollIndicator = NO;
    self.dayViewContainer.pageViewDelegate = self;
    self.dayViewContainer.pageViewDataSource = self;
}

#pragma mark - Data source requests

- (CGSize)getDayViewContentSize
{
    CGSize contentSize = CGSizeZero;
    if (self.dayViewDataSource) {
        contentSize = [self.dayViewDataSource contentSizeForDayView:self];
    } else {
        contentSize = self.bounds.size;
    }
    
    return contentSize;
}


#pragma mark - Informing delegate

- (void)informDelegateTimeScrolled
{
    if ([self.dayViewDelegate respondsToSelector:@selector(dayViewDidScrollTime:)]) {
        [self.dayViewDelegate dayViewDidScrollTime:self];
    }
}

- (void)informDelegateDateScrolledFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if ([self.dayViewDelegate respondsToSelector:@selector(dayView:didScrollFromDate:toDate:)]) {
        [self.dayViewDelegate dayView:self didScrollFromDate:fromDate toDate:toDate];
    }
}


#pragma mark - Refreshing

- (void)refreshCalendarEvents
{
    [self.dayViewContainer refreshPages];
}


#pragma mark - Scrolling

- (void)scrollToCurrentTime:(BOOL)animated
{
    ECSingleDayView* dayView = (ECSingleDayView*)self.dayViewContainer.pageView;
    [dayView scrollToCurrentTime:animated];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    [self.dayViewContainer scrollToDate:date animated:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[ECSingleDayView class]]) {
        [self informDelegateTimeScrolled];
    }
}


#pragma mark - ECInfiniatePagingDateView data source and delegate

- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView *)idv preparePage:(UIView *)page forDate:(NSDate *)date
{
    if ([page isKindOfClass:[ECSingleDayView class]]) {
        ECSingleDayView* dayView = (ECSingleDayView*)page;
        
        dayView.delegate = self;
        
        dayView.contentSize = [self getDayViewContentSize];
        dayView.displayDate = date;
        
        [dayView clearEventViews];
        [dayView addEventViews:[self.dayViewDataSource dayView:self eventViewsForDate:date]];
    }
}

- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView *)idv dateChangedTo:(NSDate *)toDate from:(NSDate *)fromDate
{
    [self informDelegateDateScrolledFromDate:fromDate toDate:toDate];
}
@end
