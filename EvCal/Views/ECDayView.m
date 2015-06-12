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
#import "ECHourLine.h"
#import "ECDayViewEventsLayout.h"

@interface ECDayView() <ECDayViewEventsLayoutDataSource>

@property (nonatomic, strong) ECDayViewEventsLayout* eventsLayout;
@property (nonatomic) BOOL eventViewsLayoutIsValid;
@property (nonatomic) BOOL hourLabelsLayoutIsValid;

@property (nonatomic, weak) UIView* allDayEventsView;
@property (nonatomic, weak) UIView* durationEventsView;

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
    self.hourLabelsLayoutIsValid = NO;
    
    self.backgroundColor = [UIColor whiteColor];
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
    
    [self setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
    self.eventViewsLayoutIsValid = NO;
    self.hourLabelsLayoutIsValid = NO;
    
    [super setFrame:frame];
}

#pragma mark - Creating Views
#define HOUR_LINE_DOT_INSET 66.0f

- (NSArray*)createHourLines
{
    NSMutableArray* mutableHourLines = [[NSMutableArray alloc] init];
    
    for (NSDate* date in [self.displayDate hoursOfDay]) {
        ECHourLine* line = [[ECHourLine alloc] initWithDate:date];
        line.hourLineInset = HOUR_LINE_DOT_INSET;
        
        [mutableHourLines addObject:line];
        [self.durationEventsView insertSubview:line atIndex:0];
    }
    
    return [mutableHourLines copy];
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

#pragma mark - Layout

#define ALL_DAY_VIEW_HEIGHT 44.0f

#define HOUR_LINE_HEIGHT    22.0f


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
                                                self.contentSize.height - ALL_DAY_VIEW_HEIGHT);
    
    DDLogDebug(@"Duration Events View Frame: %@", NSStringFromCGRect(durationEventsViewFrame));
    self.durationEventsView.frame = durationEventsViewFrame;
    
    [self layoutHourLines];
    [self layoutEventViews];
}

- (void)layoutHourLines
{
    if (!self.hourLabelsLayoutIsValid) {
        CGRect adjustedBounds = CGRectMake(self.durationEventsView.bounds.origin.x,
                                           self.durationEventsView.bounds.origin.y + HOUR_LINE_HEIGHT / 2.0f,
                                           self.durationEventsView.bounds.size.width,
                                           self.durationEventsView.bounds.size.height - HOUR_LINE_HEIGHT);
    
        for (ECHourLine* hourLine in self.hourLines) {
            CGFloat originY = [self.eventsLayout verticalPositionForDate:hourLine.date relativeToDate:self.displayDate inRect:adjustedBounds] - HOUR_LINE_HEIGHT / 2.0f;
            CGRect hourLineFrame = CGRectMake(self.durationEventsView.bounds.origin.x,
                                              originY,
                                              self.durationEventsView.bounds.size.width,
                                              HOUR_LINE_HEIGHT);
            
            DDLogDebug(@"Hour Line Frame (%@): %@", hourLine.date, NSStringFromCGRect(hourLineFrame));
            hourLine.frame = hourLineFrame;
        }
        
        self.hourLabelsLayoutIsValid = YES;
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
    CGRect eventViewsBounds = CGRectMake(self.durationEventsView.bounds.origin.x + HOUR_LINE_DOT_INSET + 6.0f,
                                         self.durationEventsView.bounds.origin.y + HOUR_LINE_HEIGHT / 2.0f,
                                         self.durationEventsView.bounds.size.width - (HOUR_LINE_DOT_INSET + 6.0f),
                                         self.durationEventsView.bounds.size.height - HOUR_LINE_HEIGHT);
    
    return eventViewsBounds;
}
@end
