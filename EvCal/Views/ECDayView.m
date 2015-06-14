//
//  ECDayView.m
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
@import EventKit;

// CocoaPods
#import "NSDate+CupertinoYankee.h"

// EvCal Classes
#import "ECDayView.h"
#import "ECEventView.h"
#import "ECTimeLine.h"
#import "ECDayViewEventsLayout.h"

@interface ECDayView() <ECDayViewEventsLayoutDataSource>

@property (nonatomic, strong) ECDayViewEventsLayout* eventsLayout;
@property (nonatomic) BOOL eventViewsLayoutIsValid;
@property (nonatomic) BOOL timeLabelsLayoutIsValid;

@property (nonatomic, weak) UIView* allDayEventsView;
@property (nonatomic, weak) UIView* durationEventsView;

@property (nonatomic, weak) ECTimeLine* currentTimeLine;
@property (nonatomic, strong) NSArray* hourLines;
@property (nonatomic, strong, readwrite) NSArray* eventViews;
@property (nonatomic, strong) NSMutableDictionary* eventViewFrames;

@end

@implementation ECDayView

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
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    self.eventViewsLayoutIsValid = NO;
    self.timeLabelsLayoutIsValid = NO;
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self addCurrentTimeLineTimer];
}

- (NSArray*)eventViews
{
    if (!_eventViews) {
        _eventViews = [[NSArray alloc] init];
    }
    
    return _eventViews;
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
        _allDayEventsView = [self createallDayEventsView];
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

- (void)setDisplayDate:(NSDate *)displayDate
{
    _displayDate = displayDate;
    
    [self updateCurrentTimeLine];
    [self setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
    self.eventViewsLayoutIsValid = NO;
    self.timeLabelsLayoutIsValid = NO;
    
    [super setFrame:frame];
}

#pragma mark - Creating Views
#define TIME_LINE_INSET 50.0f

- (NSArray*)createHourLines
{
    NSMutableArray* mutableHourLines = [[NSMutableArray alloc] init];
    
    for (NSDate* date in [self.displayDate hoursOfDay]) {
        ECTimeLine* line = [[ECTimeLine alloc] initWithDate:date];
        line.timeLineInset = TIME_LINE_INSET;
        
        [mutableHourLines addObject:line];
        [self.durationEventsView insertSubview:line atIndex:0];
    }
    
    return [mutableHourLines copy];
}

- (ECTimeLine*)createCurrentTimeLine
{
    ECTimeLine* currentTimeLine = [[ECTimeLine alloc] initWithDate:[NSDate date]];
    currentTimeLine.color = [UIColor redColor];
    currentTimeLine.backgroundColor = [UIColor clearColor];
    currentTimeLine.timeLineInset = TIME_LINE_INSET;
    currentTimeLine.dateFormatTemplate = @"j:mm";
    [self.durationEventsView addSubview:currentTimeLine];
    
    return currentTimeLine;
}

- (UIView*)createallDayEventsView
{
    UIView* allDayEventsView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:allDayEventsView];
    
    return allDayEventsView;
}

- (UIView*)createDurationEventsView
{
    UIView* durationEventsView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:durationEventsView];
    
    return durationEventsView;
}

#pragma mark - Current Time Line

- (void)addCurrentTimeLineTimer
{
    NSTimer* timer = [[NSTimer alloc] initWithFireDate:[[NSDate date] beginningOfMinute] interval:60 target:self selector:@selector(updateCurrentTimeLine) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}



- (void)updateCurrentTimeLine
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    if ([calendar isDate:self.displayDate inSameDayAsDate:[NSDate date]]) {
        self.currentTimeLine.date = [NSDate date];
        self.currentTimeLine.timeHidden = NO;
        [self changeCurrentTimeLinePosition];
    } else {
        self.currentTimeLine.timeHidden = YES;
    }
    
    [self updateHourLinesVisibility];
}

- (void)updateHourLinesVisibility
{
    for (ECTimeLine* hourLine in self.hourLines) {
        if (CGRectIntersectsRect(self.currentTimeLine.frame, hourLine.frame)) {
            hourLine.hidden = YES;
        } else {
            hourLine.hidden = NO;
        }
    }
}

#pragma mark - Layout

#define ALL_DAY_VIEW_HEIGHT 44.0f
#define HOUR_LINE_HEIGHT    15.0f


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutAllDayEventsView];
    [self layoutDurationEventsView];
}

- (void)layoutAllDayEventsView
{
    CGRect allDayFrame = CGRectZero;
    if ([self containsAllDayEventView]) {
        allDayFrame = CGRectMake(self.bounds.origin.x,
                                 self.bounds.origin.y - self.contentOffset.y,
                                 self.contentSize.width,
                                 ALL_DAY_VIEW_HEIGHT);
    }
    
    DDLogDebug(@"All Day Events View Frame: %@", NSStringFromCGRect(allDayFrame));
    self.allDayEventsView.frame = allDayFrame;
}

- (void)layoutDurationEventsView
{
    CGRect durationEventsViewFrame = CGRectMake(self.bounds.origin.x,
                                                CGRectGetMaxY(self.allDayEventsView.frame),
                                                self.contentSize.width,
                                                self.contentSize.height - self.allDayEventsView.frame.size.height);
    
    DDLogDebug(@"Duration Events View Frame: %@", NSStringFromCGRect(durationEventsViewFrame));
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
                                             HOUR_LINE_HEIGHT);

    self.currentTimeLine.frame = currentTimeLineFrame;
    [self changeCurrentTimeLinePosition];
}

- (void)changeCurrentTimeLinePosition
{
    CGFloat currentTimeLineOriginY = [self.eventsLayout verticalPositionForDate:self.currentTimeLine.date relativeToDate:self.displayDate inRect:[self adjustedDurationEventsBounds]];
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
            CGFloat originY = [self.eventsLayout verticalPositionForDate:timeLine.date relativeToDate:self.displayDate inRect:adjustedBounds] - HOUR_LINE_HEIGHT / 2.0f;
            CGRect timeLineFrame = CGRectMake(self.durationEventsView.bounds.origin.x,
                                              originY,
                                              self.durationEventsView.bounds.size.width,
                                              HOUR_LINE_HEIGHT);
            
            DDLogDebug(@"Hour Line Frame (%@): %@", timeLine.date, NSStringFromCGRect(timeLineFrame));
            timeLine.frame = timeLineFrame;
        }
        
        self.timeLabelsLayoutIsValid = YES;
    }
}

- (void)layoutEventViews
{
    if (!self.eventViewsLayoutIsValid) {
        
        [self.eventsLayout invalidateLayout];
        for (ECEventView* eventView in self.eventViews) {
            eventView.frame = [self.eventsLayout frameForEventView:eventView];
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
                      self.durationEventsView.bounds.origin.y + HOUR_LINE_HEIGHT / 2.0f,
                      self.durationEventsView.bounds.size.width,
                      self.durationEventsView.bounds.size.height - HOUR_LINE_HEIGHT);
}


#pragma mark - Update event views

- (void)setEventViewsNeedLayout
{
    self.eventViewsLayoutIsValid = NO;
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
        [self.durationEventsView addSubview:eventView];
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


#pragma mark - ECDayViewEventsLayout Datasource

- (NSArray*)eventViewsForLayout:(ECDayViewEventsLayout *)layout
{
    return self.eventViews;
}

- (NSDate*)layout:(ECDayViewEventsLayout*)layout displayDateForEventViews:(NSArray*)eventViews
{
    return self.displayDate;
}

- (CGRect)layout:(ECDayViewEventsLayout *)layout boundsForEventViews:(NSArray *)eventViews
{
    CGRect eventViewsBounds = CGRectMake(self.durationEventsView.bounds.origin.x + TIME_LINE_INSET,
                                         self.durationEventsView.bounds.origin.y + HOUR_LINE_HEIGHT / 2.0f,
                                         self.durationEventsView.bounds.size.width - TIME_LINE_INSET,
                                         self.durationEventsView.bounds.size.height - HOUR_LINE_HEIGHT);
    
    return eventViewsBounds;
}
@end
