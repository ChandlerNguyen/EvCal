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

- (instancetype)initWithFrame:(CGRect)frame displayDate:(NSDate *)date
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _displayDate = date;
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    
    if (self.displayDate && !CGRectEqualToRect(oldFrame, frame)) {
        self.dayViewContainer.frame = self.bounds;
    }
}

- (void)setDisplayDate:(NSDate *)displayDate animated:(BOOL)animated
{
    DDLogDebug(@"Changing display date: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:displayDate]);
    _displayDate = displayDate;
    
    [self.dayViewContainer scrollToDate:displayDate animated:animated];
    
    [self refreshCalendarEvents];
}

- (ECInfiniteHorizontalDatePagingView*)dayViewContainer
{
    if (!_dayViewContainer) {
        DDLogDebug(@"Creating container view with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:self.displayDate]);
        ECInfiniteHorizontalDatePagingView* dVC = [[ECInfiniteHorizontalDatePagingView alloc] initWithFrame:self.bounds
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
        DDLogDebug(@"Data source content size: %@", NSStringFromCGSize(contentSize));
    } else {
        contentSize = self.bounds.size;
        DDLogDebug(@"Using bounds for content size");
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
    NSDateFormatter* formatter = [ECLogFormatter logMessageDateFormatter];
    DDLogDebug(@"Scrolled from date: %@ to date: %@", [formatter stringFromDate:fromDate], [formatter stringFromDate:toDate]);
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

- (UIView*)pageViewForInfiniteDateView:(ECInfiniteHorizontalDatePagingView *)idv
{
    return [[ECSingleDayView alloc] init];
}

- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView *)idv preparePage:(UIView *)page forDate:(NSDate *)date
{
    DDLogDebug(@"Infinite day view requested page for date: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    if ([page isKindOfClass:[ECSingleDayView class]]) {
        ECSingleDayView* dayView = (ECSingleDayView*)page;
        
        DDLogDebug(@"Infinite day view passed single day view with display date: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:dayView.displayDate]);
        dayView.delegate = self;
        
        dayView.contentSize = [self getDayViewContentSize];
        dayView.displayDate = date;
        
        NSArray* eventViews = [self.dayViewDataSource dayView:self eventViewsForDate:date reusingViews:dayView.eventViews];
        [dayView clearEventViews];
        [dayView addEventViews:eventViews];
    }
}

- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView *)idv dateChangedTo:(NSDate *)toDate from:(NSDate *)fromDate
{
    [self informDelegateDateScrolledFromDate:fromDate toDate:toDate];
}
@end
