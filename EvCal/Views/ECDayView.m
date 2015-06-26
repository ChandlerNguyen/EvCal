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
#import "ECInfiniteDatePagingView.h"
#import "ECEventViewFactory.h"

@interface ECDayView() <UIScrollViewDelegate, ECInfiniteDatePagingViewDataSource, ECInfiniteDatePagingViewDelegate>

@property (nonatomic, weak) ECInfiniteDatePagingView* dayViewContainer;

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

- (ECInfiniteDatePagingView*)dayViewContainer
{
    if (!_dayViewContainer) {
        DDLogDebug(@"Creating container view with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:self.displayDate]);
        ECInfiniteDatePagingView* dVC = [[ECInfiniteDatePagingView alloc] initWithFrame:self.bounds
                                                                                                       date:self.displayDate];
        
        _dayViewContainer = dVC;
        [self addSubview:dVC];
        
        [self setupDayViewContainer];
    }
    
    return _dayViewContainer;
}

- (void)setupDayViewContainer
{
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
    if ([self.dayViewDelegate respondsToSelector:@selector(dayView:didScrollFrom:to:)]) {
        [self.dayViewDelegate dayView:self didScrollFrom:fromDate to:toDate];
    }
}

- (void)informDelegateEventWasSelected:(EKEvent*)event
{
    if ([self.dayViewDelegate respondsToSelector:@selector(dayView:eventWasSelected:)]) {
        [self.dayViewDelegate dayView:self eventWasSelected:event];
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
    ECSingleDayView* dayView = (ECSingleDayView*)self.dayViewContainer.visiblePage;
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

- (UIView*)pageViewForInfiniteDateView:(ECInfiniteDatePagingView *)idv
{
    return [[ECSingleDayView alloc] init];
}

- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv preparePage:(UIView *)page
{
    if ([page isKindOfClass:[ECSingleDayView class]]) {
        ECSingleDayView* dayView = (ECSingleDayView*)page;
        
        dayView.dayScrollView.delegate = self;
        
        dayView.dayScrollView.contentSize = [self getDayViewContentSize];
        
        NSArray* events = [self.dayViewDataSource dayView:self eventsForDate:dayView.date];
        NSArray* eventViews = [ECEventViewFactory eventViewsForEvents:events reusingViews:dayView.eventViews];
        
        for (ECEventView* eventView in eventViews) {
            [eventView addTarget:self action:@selector(eventViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [dayView clearEventViews];
        [dayView addEventViews:eventViews];
    }
}

- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv dateChangedFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    [self informDelegateDateScrolledFromDate:fromDate toDate:toDate];
}

#pragma mark - UI Events

- (void)eventViewTapped:(ECEventView*)sender
{
    [self informDelegateEventWasSelected:sender.event];
}
@end
