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
#import "ECEventViewFactory.h"

@interface ECDayView() <UIScrollViewDelegate, UIActionSheetDelegate, ECSingleDayViewDelegate>

@property (nonatomic, weak) UIScrollView* dayViewHorizontalScrollView;
@property (nonatomic, weak) UIScrollView* dayViewVerticalScrollView;

@property (nonatomic, strong) NSMutableArray* singleDayViews;
@property (nonatomic, weak, readonly) ECSingleDayView* leftDayView;
@property (nonatomic, weak, readonly) ECSingleDayView* centerDayView;
@property (nonatomic, weak, readonly) ECSingleDayView* rightDayView;

@property (nonatomic, strong) NSDate* changedEventStartDate;
@property (nonatomic, weak) EKEvent* changedEvent;

@property (nonatomic, strong) NSCalendar* calendar;

@end

@implementation ECDayView

#pragma mark - Constants

const static NSInteger kSingleDayViewCount =            3;
const static CGFloat kDayViewHeightDefaultMultiplier =  3.0f;

const static NSInteger kLeftDayViewIndex =              0;
const static NSInteger kCenterDayViewIndex =            1;
const static NSInteger kRightDayViewIndex =             2;


#pragma mark - Properties and Lifecycle

- (instancetype)initWithFrame:(CGRect)frame displayDate:(NSDate *)date
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _displayDate = date;
    }
    
    return self;
}

- (void)setDisplayDate:(NSDate *)displayDate animated:(BOOL)animated
{
    DDLogDebug(@"Changing display date: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:displayDate]);
    NSDate* oldDisplayDate = _displayDate;
    _displayDate = displayDate;
    
    if (![[NSCalendar currentCalendar] isDate:oldDisplayDate inSameDayAsDate:displayDate]) {
        [self refreshCalendarEvents];
        [self informDelegateDateScrolledFromDate:oldDisplayDate toDate:displayDate];
    }
    
}

- (UIScrollView*)dayViewHorizontalScrollView
{
    if (!_dayViewHorizontalScrollView) {
        UIScrollView* dayViewHorizontalScrollView = [[UIScrollView alloc] init];
        
        dayViewHorizontalScrollView.pagingEnabled = YES;
        dayViewHorizontalScrollView.showsHorizontalScrollIndicator = NO;
        dayViewHorizontalScrollView.showsVerticalScrollIndicator = NO;
        
        dayViewHorizontalScrollView.delegate = self;
        _dayViewHorizontalScrollView = dayViewHorizontalScrollView;
        [self addSubview:dayViewHorizontalScrollView];
    }
    
    return _dayViewHorizontalScrollView;
}

- (UIScrollView*)dayViewVerticalScrollView
{
    if (!_dayViewVerticalScrollView) {
        UIScrollView* dayViewVerticalScrollView = [[UIScrollView alloc] init];
        
        dayViewVerticalScrollView.showsHorizontalScrollIndicator = NO;
        dayViewVerticalScrollView.showsVerticalScrollIndicator = NO;
        
        dayViewVerticalScrollView.delegate = self;
        _dayViewVerticalScrollView = dayViewVerticalScrollView;
        [self.dayViewHorizontalScrollView addSubview:dayViewVerticalScrollView];
    }
    
    return _dayViewVerticalScrollView;
}


- (NSMutableArray*)singleDayViews
{
    if (!_singleDayViews) {
        _singleDayViews = [self createSingleDayViews];
    }
    
    return _singleDayViews;
}

- (NSMutableArray*)createSingleDayViews
{
    NSMutableArray* mutableSingleDayViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < kSingleDayViewCount; i++) {
        ECSingleDayView* dayView = [[ECSingleDayView alloc] initWithFrame:CGRectZero];
        
        dayView.singleDayViewDelegate = self;
        dayView.date = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:kCenterDayViewIndex - i toDate:self.displayDate options:0];
        
        [mutableSingleDayViews addObject:dayView];
        [self.dayViewVerticalScrollView addSubview:dayView];
    }
    
    return mutableSingleDayViews;
}

- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    if (!CGRectEqualToRect(oldFrame, frame)) {
        CGSize horizontalScrollViewContentSize = CGSizeMake(frame.size.width * kSingleDayViewCount, frame.size.height);
        self.dayViewHorizontalScrollView.contentSize = horizontalScrollViewContentSize;
        self.dayViewHorizontalScrollView.contentOffset = CGPointMake(frame.size.width, 0);
        // vertical scroll view's width should be equal to its horizontal content size which is the same as horizontal scroll view's.
        // this allows vertical scroll view to scroll within the horizontal scroll view and not pick up horizontal scroll movements.
        CGSize verticalScrollViewContentSize = CGSizeMake(frame.size.width * kSingleDayViewCount, self.dayViewHeight);
        self.dayViewVerticalScrollView.contentSize = verticalScrollViewContentSize;
    }
    [super setFrame:frame];
    
}

- (CGFloat)dayViewHeight
{
    if (_dayViewHeight == 0) {
        _dayViewHeight = self.bounds.size.height * kDayViewHeightDefaultMultiplier;
    }
    
    return _dayViewHeight;
}


- (NSCalendar*)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar autoupdatingCurrentCalendar];
    }
    
    return _calendar;
}

- (ECSingleDayView*)leftDayView
{
    return self.singleDayViews[kLeftDayViewIndex];
}

- (ECSingleDayView*)centerDayView
{
    return self.singleDayViews[kCenterDayViewIndex];
}

- (ECSingleDayView*)rightDayView
{
    return self.singleDayViews[kRightDayViewIndex];
}


#pragma mark - Updating Day Views

- (void)refreshCalendarEvents
{
    [self updateSingleDayViewsForDate:self.displayDate];
}

- (void)updateSingleDayViewsForDate:(NSDate*)date
{
    NSDate* centerPageDate = date;
    NSDate* leftPageDate = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:centerPageDate options:0];
    NSDate* rightPageDate = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:centerPageDate options:0];
    NSArray* dates = @[leftPageDate, centerPageDate, rightPageDate];
    
    for (NSInteger i = 0; i < kSingleDayViewCount; i++) {
        ECSingleDayView* singleDayView = self.singleDayViews[i];
        NSDate* date = dates[i];
        [self updateSingleDayView:singleDayView forDate:date];
    }
}

- (void)updateSingleDayView:(ECSingleDayView*)singleDayView forDate:(NSDate*)date
{
    NSArray* events = [self.dayViewDataSource dayView:self eventsForDate:date];
    NSArray* eventViews = [ECEventViewFactory eventViewsForEvents:events reusingViews:singleDayView.eventViews];
    
    singleDayView.date = date;
    
    [singleDayView clearEventViews];
    [singleDayView addEventViews:eventViews];
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


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutHorizontalDayScrollView];
    [self layoutVerticalDayScrollView];
    [self layoutSingleDayViews];
}

- (void)layoutSingleDayViews
{
    CGFloat horizontalOffset = self.dayViewHorizontalScrollView.bounds.size.width;
    
    for (NSInteger i = kLeftDayViewIndex; i <= kRightDayViewIndex; i++) {
        ECSingleDayView* singleDayView = self.singleDayViews[i];
        
        CGRect singleDayViewFrame = CGRectMake(self.dayViewVerticalScrollView.bounds.origin.x + i * horizontalOffset,
                                               self.dayViewVerticalScrollView.bounds.origin.y - self.dayViewVerticalScrollView.contentOffset.y,
                                               self.dayViewVerticalScrollView.bounds.size.width / kSingleDayViewCount,
                                               self.dayViewHeight);
        
        singleDayView.frame = singleDayViewFrame;
    }
}

- (void)layoutHorizontalDayScrollView
{
    CGRect dayViewHorizontalScrollViewFrame = self.bounds;
    self.dayViewHorizontalScrollView.frame = dayViewHorizontalScrollViewFrame;
}

- (void)layoutVerticalDayScrollView
{
    CGRect verticalDayScrollViewFrame = CGRectMake(self.dayViewHorizontalScrollView.bounds.origin.x - self.dayViewHorizontalScrollView.contentOffset.x,
                                                   self.dayViewHorizontalScrollView.bounds.origin.y,
                                                   self.dayViewVerticalScrollView.contentSize.width,
                                                   self.bounds.size.height);
    
    self.dayViewVerticalScrollView.frame = verticalDayScrollViewFrame;
}


#pragma mark - Scrolling

- (void)updateCurrentTime
{
#warning implement
}

- (void)scrollToCurrentTime:(BOOL)animated
{
#warning Implement
    [self informDelegateTimeScrolled];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    DDLogDebug(@"Scroll to date: %@", date);
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self informDelegateTimeScrolled];
//}

// This method assumes that the date of the page in the center page index should
// be used to determine the values of the other pages. The center page date MUST
// be updated and correct prior to this method's invocation.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.dayViewHorizontalScrollView]) {
        
        ECSingleDayView* visibleDayView = [self getVisibleDayView];
        NSComparisonResult dateComparison = [visibleDayView.date compare:self.displayDate];
        
        switch (dateComparison) {
            case NSOrderedDescending: // center day view date is after current display date
                
                [self swapSingleDayViewAtIndex:kLeftDayViewIndex toIndex:kRightDayViewIndex withCenterDate:visibleDayView.date];
                
                // reset scroll view to center
                self.dayViewHorizontalScrollView.contentOffset = CGPointMake(self.dayViewHorizontalScrollView.bounds.size.width, 0);
                // reset views within scroll view
                [self layoutVerticalDayScrollView];
                [self layoutSingleDayViews];
                
                break;
                
            default:
                break;
        }
    }
}

- (ECSingleDayView*)getVisibleDayView
{
    CGFloat horizontalOffset = self.dayViewHorizontalScrollView.bounds.origin.x;
    
    if (horizontalOffset < self.dayViewHorizontalScrollView.bounds.size.width) {
        return self.leftDayView;
    } else if (horizontalOffset >= self.dayViewHorizontalScrollView.bounds.size.width * 2) {
        return self.rightDayView;
    } else {
        return self.centerDayView;
    }
}

// The center date is the new center date after the page is swapped
- (void)swapSingleDayViewAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex withCenterDate:(NSDate*)date
{
    NSInteger dateDelta = kCenterDayViewIndex - newIndex;
    NSDate* newSwappedPageDate = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:dateDelta toDate:date options:0];
    
    ECSingleDayView* swappedSingleDayView = self.singleDayViews[oldIndex];
    [self updateSingleDayView:swappedSingleDayView forDate:newSwappedPageDate];
    
    [self.singleDayViews removeObjectAtIndex:oldIndex];
    [self.singleDayViews insertObject:swappedSingleDayView atIndex:newIndex];
}



//- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv preparePage:(UIView *)page
//{
//    if ([page isKindOfClass:[ECSingleDayView class]]) {
//        ECSingleDayView* dayView = (ECSingleDayView*)page;
//        dayView.singleDayViewDelegate = self;
//        
//        dayView.dayScrollView.delegate = self;
//        
//        dayView.dayScrollView.contentSize = [self getDayViewContentSize];
//        
//        NSArray* events = [self.dayViewDataSource dayView:self eventsForDate:dayView.date];
//        NSArray* eventViews = [ECEventViewFactory eventViewsForEvents:events reusingViews:dayView.eventViews];
//        
//        for (ECEventView* eventView in eventViews) {
//            [eventView addTarget:self action:@selector(eventViewTapped:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        
//        [dayView clearEventViews];
//        [dayView addEventViews:eventViews];
//    }
//}

//- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv dateChangedFrom:(NSDate *)fromDate to:(NSDate *)toDate
//{
//    if (![[NSCalendar currentCalendar] isDate:toDate inSameDayAsDate:self.displayDate]) {
//        _displayDate = toDate;
//        [self informDelegateDateScrolledFromDate:fromDate toDate:toDate];
//    }
//}


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

- (void)eventViewWasSelected:(ECEventView *)eventView
{
    [self informDelegateEventWasSelected:eventView.event];
}

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


@end
