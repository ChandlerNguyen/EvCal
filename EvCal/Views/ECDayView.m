//
//  ECDayView.m
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//



// EvCal Classes
@import EventKit;
#import "ECDayView.h"
#import "ECSingleDayView.h"
#import "ECInfiniteDatePagingView.h"
#import "ECEventViewFactory.h"

@interface ECDayView() <UIScrollViewDelegate, UIActionSheetDelegate, ECInfiniteDatePagingViewDataSource, ECInfiniteDatePagingViewDelegate, ECSingleDayViewDelegate>

@property (nonatomic, weak) ECInfiniteDatePagingView* dayViewContainer;
@property (nonatomic, strong) NSMutableArray* singleDayViews;

@property (nonatomic, strong) NSDate* changedEventStartDate;
@property (nonatomic, weak) EKEvent* changedEvent;

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
    NSDate* oldDisplayDate = _displayDate;
    _displayDate = displayDate;
    
    if (![[NSCalendar currentCalendar] isDate:oldDisplayDate inSameDayAsDate:displayDate]) {
        [self.dayViewContainer scrollToDate:displayDate animated:animated];
        [self refreshCalendarEvents];
        [self informDelegateDateScrolledFromDate:oldDisplayDate toDate:displayDate];
    }
    
}

- (NSMutableArray*)singleDayViews
{
    if (!_singleDayViews) {
        _singleDayViews = [[NSMutableArray alloc] init];
    }
    
    return _singleDayViews;
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

- (void)updateCurrentTime
{
    if ([self.dayViewContainer.visiblePage isKindOfClass:[ECSingleDayView class]]) {
        ECSingleDayView* currentDayView = (ECSingleDayView*)self.dayViewContainer.visiblePage;
        [currentDayView updateCurrentTime];
    }
}


#pragma mark - Scrolling

- (void)scrollToCurrentTime:(BOOL)animated
{
    ECSingleDayView* dayView = (ECSingleDayView*)self.dayViewContainer.visiblePage;
    [dayView scrollToCurrentTime:animated];
    [self informDelegateTimeScrolled];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    [self.dayViewContainer scrollToDate:date animated:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    ECSingleDayView* visibleDayView = (ECSingleDayView*)self.dayViewContainer.visiblePage;
    NSDate* visibleDate = visibleDayView.visibleDate;
    for (ECSingleDayView* dayView in self.dayViewContainer.pages) {
        if (dayView != visibleDayView) {
            [dayView scrollToTime:visibleDate animated:NO];
        }
    }
    [self informDelegateTimeScrolled];
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
        dayView.singleDayViewDelegate = self;
        
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
    if (![[NSCalendar currentCalendar] isDate:toDate inSameDayAsDate:self.displayDate]) {
        _displayDate = toDate;
        [self informDelegateDateScrolledFromDate:fromDate toDate:toDate];
    }
}


#pragma mark - Action Sheets

- (void)presentEventChangeSpanActionSheet
{
    UIActionSheet* saveSpanActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ECDayView.This is a repeating event", @"The changed event repeats")
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"ECDayView.Save for this event only", @"Only this occurrence of the event should be changed"), NSLocalizedString(@"ECDayView.Save for future events", @"All future occurrences of the event should be changed"), nil];
    
    [saveSpanActionSheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"ECDayView.Save for this event only", @"Only this occurrence of the event should be changed")]) {
        [self informDelegateEvent:self.changedEvent dateChanged:self.changedEventStartDate span:EKSpanThisEvent];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"ECDayView.Save for future events", @"All future occurrences of the event should be changed")]) {
        [self informDelegateEvent:self.changedEvent dateChanged:self.changedEventStartDate span:EKSpanFutureEvents];
    }
}


#pragma mark - ECSingleDayView Delegate

- (void)eventView:(ECEventView *)eventView wasDraggedToDate:(NSDate *)date
{
    EKEvent* event = eventView.event;
    
    if (event.hasRecurrenceRules) {
        self.changedEvent = event;
        self.changedEventStartDate = date;
        [self presentEventChangeSpanActionSheet];
    } else {
        [self informDelegateEvent:eventView.event dateChanged:date span:EKSpanThisEvent];
    }
}

- (void)informDelegateEvent:(EKEvent*)event dateChanged:(NSDate*)date span:(EKSpan)span
{
    if ([self.dayViewDelegate respondsToSelector:@selector(dayView:event:startDateChanged:span:)]) {
        [self.dayViewDelegate dayView:self event:event startDateChanged:date span:span];
    }
    
    self.changedEvent = nil;
    self.changedEventStartDate = nil;
}

#pragma mark - UI Events

- (void)eventViewTapped:(ECEventView*)sender
{
    [self informDelegateEventWasSelected:sender.event];
}
@end
