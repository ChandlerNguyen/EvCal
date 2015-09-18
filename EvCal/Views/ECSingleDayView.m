//
//  ECSingleDayView.m
//  EvCal
//
//  Created by Tom on 6/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
@import EventKit;

// Helpers
@import Tunits;
#import "UIColor+ECAdditions.h"
#import "NSDate+ECEventAdditions.h"

// EvCal Classes
#import "ECSingleDayView.h"
#import "ECDayViewEventsLayout.h"
#import "ECEventView.h"
#import "ECTimeLine.h"

@interface ECSingleDayView() <UIScrollViewDelegate, ECDayViewEventsLayoutDataSource, ECEventViewDelegate>

// Layout
@property (nonatomic, strong) ECDayViewEventsLayout* eventsLayout;
@property (nonatomic) BOOL eventViewsLayoutIsValid;
@property (nonatomic) BOOL timeLabelsLayoutIsValid;

// Views
@property (nonatomic, weak, readwrite) UIScrollView* dayScrollView;
@property (nonatomic, weak) UIView* allDayEventsView;
@property (nonatomic, weak) UILabel* allDayLabel;
@property (nonatomic, weak) UIView* durationEventsView;
@property (nonatomic, strong, readwrite) NSArray* eventViews;
@property (nonatomic, strong) NSMutableDictionary* eventViewFrames;

// State
@property (nonatomic) BOOL dateIsSameDayAsToday;
@property (nonatomic) BOOL scrollingToTime;

// Time Lines
@property (nonatomic, weak) ECTimeLine* currentTimeLine;
@property (nonatomic, strong) NSArray* hourLines;

// Dragging Events
@property (nonatomic, weak) ECTimeLine* draggingEventViewTimeLine;
@property (nonatomic) CGFloat previousDragLocationY;
@end

@implementation ECSingleDayView

#pragma mark - Lifecycle and Properties

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.dayScrollView.showsHorizontalScrollIndicator = NO;
    self.dayScrollView.showsVerticalScrollIndicator = NO;
    
    self.eventViewsLayoutIsValid = NO;
    self.timeLabelsLayoutIsValid = NO;
    
    self.scrollingToTime = NO;
    
    [self addCurrentTimeLineTimer];
}

- (UIScrollView*)dayScrollView
{
    if (!_dayScrollView) {
        UIScrollView* dayScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        dayScrollView.backgroundColor = [UIColor whiteColor];
        dayScrollView.delegate = self;
        
        _dayScrollView = dayScrollView;
        [self addSubview:dayScrollView];
    }
    
    return _dayScrollView;
}

- (NSArray*)eventViews
{
    if (!_eventViews) {
        _eventViews = [[NSArray alloc] init];
    }
    
    return _eventViews;
}

- (NSDate*)visibleDate
{
    CGRect displayBounds = [self layout:self.eventsLayout boundsForEventViews:nil];
    NSDate* visibleDate = [self.eventsLayout dateForVerticalPosition:self.dayScrollView.contentOffset.y + kHourLineHeight / 2.0f
                                                      relativeToDate:self.date
                                                              bounds:displayBounds];
    
    return visibleDate;
}

- (ECDayViewEventsLayout*)eventsLayout
{
    if (!_eventsLayout) {
        _eventsLayout = [[ECDayViewEventsLayout alloc] init];
        _eventsLayout.layoutDataSource = self;
    }
    
    return _eventsLayout;
}

- (UIView*)allDayEventsView
{
    if (!_allDayEventsView) {
        _allDayEventsView = [self createAllDayEventsView];
    }
    
    return _allDayEventsView;
}

- (UIView*)durationEventsView
{
    if (!_durationEventsView) {
        _durationEventsView = [self createDurationEventsView];
    }
    
    return _durationEventsView;
}

- (ECTimeLine*)currentTimeLine
{
    if (!_currentTimeLine) {
        _currentTimeLine = [self createCurrentTimeLine];
    }
    
    return _currentTimeLine;
}

- (NSArray*)hourLines
{
    if (!_hourLines) {
        _hourLines = [self createHourLines];
    }
    
    return _hourLines;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    DDLogDebug(@"Display date changed: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    
    self.eventViewsLayoutIsValid = NO;
    
    [self.eventsLayout invalidateLayout];
    [self updateCurrentTime];
}

- (void)setFrame:(CGRect)frame
{
    self.eventViewsLayoutIsValid = NO;
    self.timeLabelsLayoutIsValid = NO;
    
    if (!CGRectEqualToRect(self.frame, frame)) {
        CGSize dayScrollViewContentSize = CGSizeMake(frame.size.width, 1400);
        self.dayScrollView.contentSize = dayScrollViewContentSize;
    }
    
    [super setFrame:frame];
}

#pragma mark - Creating Views

- (NSArray*)createHourLines
{
    NSMutableArray* mutableHourLines = [[NSMutableArray alloc] init];
    
    for (NSDate* date in [TimeUnit hoursOfDay:self.date]) {
        ECTimeLine* line = [[ECTimeLine alloc] initWithDate:date];
        
        [mutableHourLines addObject:line];
        [self.durationEventsView insertSubview:line atIndex:0];
    }
    
    return [mutableHourLines copy];
}

- (ECTimeLine*)createCurrentTimeLine
{
    ECTimeLine* currentTimeLine = [[ECTimeLine alloc] initWithDate:[NSDate date]];
    currentTimeLine.color = [UIColor ecRedColor];
    currentTimeLine.backgroundColor = [UIColor clearColor];
    currentTimeLine.lineThickness = ECTimeLineThicknessBold;
    currentTimeLine.dateFormatTemplate = @"j:mm";
    [self.durationEventsView addSubview:currentTimeLine];
    
    return currentTimeLine;
}

- (UIView*)createAllDayEventsView
{
    UIView* allDayEventsView = [[UIView alloc] initWithFrame:CGRectZero];
    allDayEventsView.backgroundColor = [UIColor lightGrayColor];
    
    [self addLabelToAllDayView:allDayEventsView];
    [self addSubview:allDayEventsView];
    
    return allDayEventsView;
}

- (void)addLabelToAllDayView:(UIView*)allDayEventsView
{
    UILabel* allDayLabel = [[UILabel alloc] init];
    allDayLabel.textColor = [UIColor darkGrayColor];
    allDayLabel.text = NSLocalizedString(@"ECSingleDayView.All Day", @"Events that last all day");
    self.allDayLabel = allDayLabel;
    [allDayEventsView addSubview:allDayLabel];
}

- (UIView*)createDurationEventsView
{
    UIView* durationEventsView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.dayScrollView addSubview:durationEventsView];
    
    return durationEventsView;
}

#pragma mark - Current Time Line

- (void)addCurrentTimeLineTimer
{
#warning add beginning of minute class to Tunits
//    NSTimer* timer = [[NSTimer alloc] initWithFireDate:[[[TimeUnit alloc] init] ] interval:60 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)updateCurrentTime
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    self.dateIsSameDayAsToday = [calendar isDate:self.date inSameDayAsDate:[NSDate date]];
    if (self.dateIsSameDayAsToday) {
        self.currentTimeLine.date = [NSDate date];
        self.currentTimeLine.hidden = NO;
        [self changeCurrentTimeLinePosition];
    } else {
        self.currentTimeLine.hidden = YES;
    }
    
    [self updateHourLinesVisibility];
}

- (void)updateHourLinesVisibility
{
    for (ECTimeLine* hourLine in self.hourLines) {
        BOOL currentTimeLineIntersectsHourLine = CGRectIntersectsRect(self.currentTimeLine.frame, hourLine.frame);
        BOOL draggingTimeLineIntersectsHourLine = (!!self.draggingEventViewTimeLine) && CGRectIntersectsRect(self.draggingEventViewTimeLine.frame, hourLine.frame);
        if (currentTimeLineIntersectsHourLine || draggingTimeLineIntersectsHourLine) {
            hourLine.timeHidden = self.dateIsSameDayAsToday;
        } else {
            hourLine.timeHidden = NO;
        }
    }
}

#pragma mark - Layout

const static CGFloat kAllDayViewHeight =            33.0f;
const static CGFloat kHourLineHeight =              15.0f;
const static CGFloat kEventViewHorizontalPadding =  4.0f;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutDayScrollView];
    [self layoutAllDayEventsView];
    [self layoutDurationEventsView];
}

- (void)layoutDayScrollView
{
    CGFloat allDayEventViewHeight = ([self containsAllDayEventView]) ? self.bounds.size.height - kAllDayViewHeight : self.bounds.size.height;
    CGRect dayScrollViewFrame = CGRectMake(self.bounds.origin.x,
                                           CGRectGetMaxY(self.allDayEventsView.frame),
                                           self.bounds.size.width,
                                           allDayEventViewHeight);
    self.dayScrollView.frame = dayScrollViewFrame;
}

- (void)layoutAllDayEventsView
{
    CGRect allDayFrame = CGRectZero;
    if ([self containsAllDayEventView]) {
        allDayFrame = CGRectMake(self.bounds.origin.x,
                                 self.bounds.origin.y,
                                 self.bounds.size.width,
                                 kAllDayViewHeight);
    }
    
    self.allDayEventsView.frame = allDayFrame;
    [self layoutAllDayLabel];
}

- (void)layoutAllDayLabel
{
    CGFloat allDayLabelWidth = ceilf([self.allDayLabel.text boundingRectWithSize:self.allDayEventsView.frame.size
                                                                         options:0
                                                                      attributes:@{NSFontAttributeName : self.allDayLabel.font}
                                                                         context:nil].size.width);
    CGRect allDayLabelFrame = CGRectMake(self.allDayEventsView.bounds.origin.x + kEventViewHorizontalPadding,
                                         self.allDayEventsView.bounds.origin.y,
                                         allDayLabelWidth,
                                         self.allDayEventsView.bounds.size.height);
    self.allDayLabel.frame = allDayLabelFrame;
}

- (void)layoutDurationEventsView
{
    CGRect durationEventsViewFrame = CGRectMake(self.dayScrollView.bounds.origin.x,
                                                self.dayScrollView.bounds.origin.y - self.dayScrollView.contentOffset.y,
                                                self.dayScrollView.contentSize.width,
                                                self.dayScrollView.contentSize.height);
    
    self.durationEventsView.frame = durationEventsViewFrame;
    
    [self layoutCurrentTimeLine];
    [self layoutHourLines];
    [self layoutEventViews];
}

- (void)layoutCurrentTimeLine
{
    CGRect currentTimeLineFrame = CGRectMake(self.durationEventsView.bounds.origin.x,
                                             self.durationEventsView.bounds.origin.y,
                                             self.durationEventsView.bounds.size.width,
                                             kHourLineHeight);
    self.currentTimeLine.frame = currentTimeLineFrame;
    [self changeCurrentTimeLinePosition];
}

- (void)changeCurrentTimeLinePosition
{
    CGFloat currentTimeLineOriginY = [self.eventsLayout verticalPositionForDate:self.currentTimeLine.date
                                                                 relativeToDate:self.date
                                                                         bounds:[self adjustedDurationEventsBounds]] - kHourLineHeight / 2.0f;
    CGPoint currentTimeLineOrigin = CGPointMake(self.durationEventsView.bounds.origin.x, currentTimeLineOriginY);
    
    CGRect currentTimeLineFrame = self.currentTimeLine.frame;
    currentTimeLineFrame.origin = currentTimeLineOrigin;
    self.currentTimeLine.frame = currentTimeLineFrame;
}

- (void)layoutHourLines
{
    if (!self.timeLabelsLayoutIsValid) {
        CGRect adjustedBounds = [self adjustedDurationEventsBounds];
        
        for (ECTimeLine* timeLine in self.hourLines) {
            CGFloat originY = [self.eventsLayout verticalPositionForDate:timeLine.date relativeToDate:self.date bounds:adjustedBounds] - kHourLineHeight / 2.0f;
            CGRect timeLineFrame = CGRectMake(self.durationEventsView.bounds.origin.x,
                                              originY,
                                              self.durationEventsView.bounds.size.width,
                                              kHourLineHeight);
            timeLine.frame = timeLineFrame;
        }
        
        self.timeLabelsLayoutIsValid = YES;
    }
}

- (void)layoutEventViews
{
    if (!self.eventViewsLayoutIsValid) {
        
        NSMutableArray* allDayEvents = [[NSMutableArray alloc] init];
        
        [self.eventsLayout invalidateLayout];
        for (ECEventView* eventView in self.eventViews) {
            if (!eventView.event.isAllDay) {
                eventView.frame = [self.eventsLayout frameForEventView:eventView];
            } else {
                [allDayEvents addObject:eventView];
            }
        }
        
        if (allDayEvents.count > 0) {
            CGFloat allDayEventViewsCurrentOffsetX = CGRectGetMaxX(self.allDayLabel.frame) + kEventViewHorizontalPadding;
            CGFloat allDayEventViewsWidth = floor((self.allDayEventsView.bounds.size.width - self.allDayLabel.frame.size.width - 3 * kEventViewHorizontalPadding) / allDayEvents.count);
            for (ECEventView* allDayEventView in allDayEvents) {
                CGRect allDayEventViewFrame = CGRectMake(allDayEventViewsCurrentOffsetX,
                                                         self.allDayEventsView.bounds.origin.y,
                                                         allDayEventViewsWidth,
                                                         kAllDayViewHeight);
                allDayEventView.frame = allDayEventViewFrame;
                
                allDayEventViewsCurrentOffsetX = CGRectGetMaxX(allDayEventViewFrame);
            }
        }
        
        self.eventViewsLayoutIsValid = YES;
    }
}

- (BOOL)containsAllDayEventView
{
    for (ECEventView* eventView in self.eventViews) {
        if (eventView.event.isAllDay) {
            return YES;
        }
    }
    
    return NO;
}

- (CGRect)adjustedDurationEventsBounds
{
    return CGRectMake(self.durationEventsView.bounds.origin.x,
                      self.durationEventsView.bounds.origin.y + kHourLineHeight / 2.0f,
                      self.durationEventsView.bounds.size.width,
                      self.durationEventsView.bounds.size.height - kHourLineHeight);
}


#pragma mark - Update event views

- (void)setEventViewsNeedLayout
{
    self.eventViewsLayoutIsValid = NO;
    [self.eventsLayout invalidateLayout];
    [self setNeedsLayout];
}

- (void)addEventView:(ECEventView *)eventView
{
    if (eventView) {
        [self addEventViewToView:eventView];
        
        NSMutableArray* mutableEventViews = [self.eventViews mutableCopy];
        [mutableEventViews addObject:eventView];
        self.eventViews = [mutableEventViews copy];
        
        [self setEventViewsNeedLayout];
    } else {
        DDLogWarn(@"Adding nil event view to ECDayView");
    }
}

- (void)addEventViews:(NSArray *)eventViews
{
    NSMutableArray* mutableEventViews = [self.eventViews mutableCopy];
    if (eventViews) {
        for (ECEventView* eventView in eventViews) {
            [self addEventViewToView:eventView];
            
            [mutableEventViews addObject:eventView];
        }
        
        self.eventViews = [mutableEventViews copy];
        
        [self setEventViewsNeedLayout];
    } else {
        DDLogWarn(@"Adding nil array of event views to ECDayView");
    }
}

- (void)addEventViewToView:(ECEventView*)eventView
{
    if (!eventView.event.isAllDay) {
        eventView.eventViewDelegate = self;
        [self.durationEventsView insertSubview:eventView belowSubview:self.currentTimeLine];
    } else {
        [self.allDayEventsView addSubview:eventView];
    }
}

- (void)removeEventView:(ECEventView *)eventView
{
    if (eventView) {
        NSMutableArray* mutableEventViews = [self.eventViews mutableCopy];
        [mutableEventViews removeObject:eventView];
        self.eventViews = [mutableEventViews copy];
        [eventView removeFromSuperview];
        
        [self setEventViewsNeedLayout];
    } else {
        DDLogWarn(@"Removing nil event view from ECDayView");
    }
}

- (void)removeEventViews:(NSArray *)eventViews
{
    if (eventViews) {
        NSMutableIndexSet* victims = [NSMutableIndexSet indexSet];
        for (ECEventView* eventView in eventViews) {
            [eventView removeFromSuperview];
            NSUInteger eventViewIndex = [self.eventViews indexOfObject:eventView];
            
            if (eventViewIndex != NSNotFound)
                [victims addIndex:eventViewIndex];
        }
        NSMutableArray* mutableEventViews = [self.eventViews mutableCopy];
        [mutableEventViews removeObjectsAtIndexes:victims];
        self.eventViews = [mutableEventViews copy];
        
        [self setEventViewsNeedLayout];
    } else {
        DDLogWarn(@"Removing nil array of event views from ECDayView");
    }
}

- (void)clearEventViews
{
    [self removeEventViews:self.eventViews];
    [self setEventViewsNeedLayout];
}

- (void)refreshEventViewLayout
{
    [self setEventViewsNeedLayout];
}


#pragma mark - ECDayViewEventsLayout Datasource

- (NSArray*)eventViewsForLayout:(ECDayViewEventsLayout *)layout
{
    return self.eventViews;
}

- (NSDate*)layout:(ECDayViewEventsLayout*)layout displayDateForEventViews:(NSArray*)eventViews
{
    return self.date;
}

- (CGRect)layout:(ECDayViewEventsLayout *)layout boundsForEventViews:(NSArray *)eventViews
{
    CGRect eventViewsBounds = CGRectMake(self.durationEventsView.bounds.origin.x + self.currentTimeLine.timeLineInset + kEventViewHorizontalPadding,
                                         self.durationEventsView.bounds.origin.y + kHourLineHeight / 2.0f,
                                         self.durationEventsView.bounds.size.width - (self.currentTimeLine.timeLineInset + 2 * kEventViewHorizontalPadding),
                                         self.durationEventsView.bounds.size.height - kHourLineHeight);
    
    return eventViewsBounds;
}


#pragma mark - Auto Scrolling

- (void)scrollToCurrentTime:(BOOL)animated
{
    CGRect topHalfOfVisibleRect = CGRectMake(self.dayScrollView.contentOffset.x,
                                             self.dayScrollView.contentOffset.y,
                                             self.dayScrollView.bounds.size.width,
                                             self.dayScrollView.bounds.size.height / 2.0f);
    CGRect convertedCurrentTimeLineFrame = [self convertRect:self.currentTimeLine.frame fromView:self.durationEventsView];
    
    if (!CGRectIntersectsRect(topHalfOfVisibleRect, convertedCurrentTimeLineFrame)) {
        [self scrollToTime:[TimeUnit beginningOfHour:[NSDate date]] animated:animated];
    }
}

- (void)scrollToFirstEvent:(BOOL)animated
{
    ECEventView* firstEventView = [self.eventViews sortedArrayUsingSelector:@selector(compare:)].firstObject;
    [self scrollToTime:firstEventView.event.startDate animated:animated];
}

- (void)scrollToTime:(NSDate*)time animated:(BOOL)animated
{
    CGFloat timeOffsetY = [self.eventsLayout verticalPositionForDate:time relativeToDate:self.date bounds:self.durationEventsView.bounds] + self.allDayEventsView.frame.size.height;
    timeOffsetY = MIN(timeOffsetY, self.dayScrollView.contentSize.height - self.dayScrollView.bounds.size.height) - kHourLineHeight / 2.0f;
    CGPoint timeOffset = CGPointMake(self.bounds.origin.x, timeOffsetY);
    
    self.scrollingToTime = YES;
    [self.dayScrollView setContentOffset:timeOffset animated:animated];
}


#pragma mark ECEventView Delegate

- (void)eventView:(ECEventView *)eventView wasTapped:(UITapGestureRecognizer *)tapRecognizer
{
    [self informDelegateThatEventViewWasSelected:eventView];
}

- (void)informDelegateThatEventViewWasSelected:(ECEventView*)eventView
{
    if ([self.singleDayViewDelegate respondsToSelector:@selector(eventViewWasSelected:)]) {
        [self.singleDayViewDelegate eventViewWasSelected:eventView];
    }
}

- (void)eventView:(ECEventView *)eventView didBeginDragging:(UILongPressGestureRecognizer *)dragRecognizer
{
    ECTimeLine* eventTimeLine = [[ECTimeLine alloc] initWithDate:eventView.event.startDate];
    
    eventTimeLine.lineThickness = ECTimeLineThicknessBlack;
    eventTimeLine.color = [UIColor eventViewBackgroundColorForCGColor:eventView.event.calendar.CGColor];
    eventTimeLine.dateFormatTemplate = @"j:mm";
    
    CGFloat eventTimeLineY = [self.eventsLayout verticalPositionForDate:eventTimeLine.date relativeToDate:self.date bounds:[self adjustedDurationEventsBounds]] - kHourLineHeight / 2.0f;
    CGRect eventTimeLineFrame = CGRectMake(self.bounds.origin.x,
                                           eventTimeLineY,
                                           self.bounds.size.width,
                                           kHourLineHeight);
    eventTimeLine.frame = eventTimeLineFrame;
    self.draggingEventViewTimeLine = eventTimeLine;
    self.previousDragLocationY = [dragRecognizer locationInView:self.durationEventsView].y;
    
    [self.durationEventsView addSubview:eventTimeLine];
    [self updateHourLinesVisibility];
}

- (void)eventView:(ECEventView *)eventView didDrag:(UILongPressGestureRecognizer *)dragRecognizer
{
    CGFloat dragLocationY = [dragRecognizer locationInView:self.durationEventsView].y;
    CGFloat deltaY = dragLocationY - self.previousDragLocationY;
    self.previousDragLocationY = dragLocationY;
    
    CGPoint newEventViewCenter = CGPointMake(eventView.center.x, eventView.center.y + deltaY);
    eventView.center = newEventViewCenter;
    
    NSDate* draggedDate = [self.eventsLayout dateForVerticalPosition:eventView.frame.origin.y
                                                      relativeToDate:self.date
                                                              bounds:[self layout:self.eventsLayout boundsForEventViews:nil]];
    
    NSDate* newEventStartDate = [draggedDate nearestFiveMinutes];
    self.draggingEventViewTimeLine.date = newEventStartDate;
    CGFloat eventTimeLineY = [self.eventsLayout verticalPositionForDate:self.draggingEventViewTimeLine.date
                                                         relativeToDate:self.date
                                                                 bounds:[self adjustedDurationEventsBounds]] - kHourLineHeight / 2.0f;
    CGRect eventTimeLineFrame = CGRectMake(self.bounds.origin.x,
                                           eventTimeLineY,
                                           self.bounds.size.width,
                                           kHourLineHeight);
    self.draggingEventViewTimeLine.frame = eventTimeLineFrame;
    
    [self updateHourLinesVisibility];
}

- (void)eventView:(ECEventView *)eventView didEndDragging:(UILongPressGestureRecognizer *)dragRecognizer
{
    [self informDelegateThatEventViewDateChanged:eventView];
    
    [self.draggingEventViewTimeLine removeFromSuperview];
    self.draggingEventViewTimeLine = nil;
    
    [self.eventsLayout invalidateLayout];
    [self updateHourLinesVisibility];
}

- (void)informDelegateThatEventViewDateChanged:(ECEventView*)eventView
{
    if ([self.singleDayViewDelegate respondsToSelector:@selector(eventView:wasDraggedToDate:)]) {
        [self.singleDayViewDelegate eventView:eventView wasDraggedToDate:self.draggingEventViewTimeLine.date];
    }
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.scrollingToTime) {
        [self informDelegateThatVisibleDateWasChanged];
    }
    
    self.scrollingToTime = NO;
}

- (void)informDelegateThatVisibleDateWasChanged
{
    if ([self.singleDayViewDelegate respondsToSelector:@selector(singleDayView:visibleDateChanged:)]) {
        [self.singleDayViewDelegate singleDayView:self visibleDateChanged:self.visibleDate];
    }
}

@end