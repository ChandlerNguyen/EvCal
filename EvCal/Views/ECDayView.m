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

@interface ECDayView()

@property (nonatomic) BOOL eventViewsLayoutIsValid;

@property (nonatomic, weak) UIView* allDayEventsView;
@property (nonatomic, weak) UIView* durationEventsView;

@property (nonatomic, strong) NSArray* hourLines;
@property (nonatomic, strong, readwrite) NSArray* eventViews;
@property (nonatomic, strong) NSMutableDictionary* eventViewFrames;

@end

@implementation ECDayView

#pragma mark - Lifecycle and Properties

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.eventViewsLayoutIsValid = NO;
    }
    
    return self;
}

- (NSArray*)eventViews
{
    if (!_eventViews) {
        _eventViews = [[NSArray alloc] init];
    }
    
    return _eventViews;
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

#pragma mark - Creating Views

- (NSArray*)createHourLines
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSMutableArray* mutableHourLines = [[NSMutableArray alloc] init];
    
    for (NSDate* date in [self.displayDate hoursOfDay]) {
        ECHourLine* line = [[ECHourLine alloc] initWithHour:[calendar component:NSCalendarUnitHour fromDate:date]];
        
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
#define HOUR_LINE_DOT_INSET 80.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutAllDayEventsView];
    [self layoutDurationEventsView];
}

- (void)layoutAllDayEventsView
{
    CGRect allDayFrame = CGRectMake(self.bounds.origin.x,
                                    self.bounds.origin.y - self.contentOffset.y,
                                    self.contentSize.width,
                                    ALL_DAY_VIEW_HEIGHT);
    
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
    CGFloat yOffset = floorf(self.durationEventsView.bounds.size.height / self.hourLines.count);
    for (ECHourLine* hourLine in self.hourLines) {
        CGFloat originY = self.durationEventsView.bounds.origin.y + hourLine.hour * yOffset;
        CGRect hourLineFrame = CGRectMake(self.durationEventsView.bounds.origin.x,
                                          originY,
                                          self.durationEventsView.bounds.size.width,
                                          HOUR_LINE_HEIGHT);
        
        DDLogDebug(@"Hour Line Frame (%lu): %@", hourLine.hour, NSStringFromCGRect(hourLineFrame));
        hourLine.frame = hourLineFrame;
    }
}

- (void)layoutEventViews
{
    if (!self.eventViewsLayoutIsValid) {
        // Prepare layout state
        CGFloat width = self.bounds.size.width;
        NSDate* lastEndDate = nil;
        
        NSArray* hours = [self.displayDate hoursOfDay];
        
        self.eventViews = [self.eventViews sortedArrayUsingSelector:@selector(compare:)];
        
        // Columns is a jagged two dimensional array
        NSMutableArray* columns = [[NSMutableArray alloc] init];
        
        for (ECEventView* eventView in self.eventViews) {
            // this view doesn't overlap the previous cluster of views
            if (lastEndDate && [eventView.event.startDate compare:lastEndDate] == NSOrderedDescending) {
                [self layoutColumns:columns width:width displayedHours:hours];
                
                // start new cluster
                columns = [@[] mutableCopy];
                lastEndDate = nil;
            }
            
            BOOL placed = NO;
            for (NSInteger i = 0; i < columns.count; i++) {
                // determine if view can be added to the end of a current column
                NSArray* column = columns[i];
                if (![self eventView:eventView overlapsEventView:[column lastObject]]) {
                    // add view to end of column
                    columns[i] = [column arrayByAddingObject:eventView];
                    placed = YES;
                    break;
                }
            }
            
            // view overlaps all columns, add a new column
            if (!placed) {
                [columns addObject:@[eventView]];
            }
            
            // last date isn't set or the view's end date is later than current end date
            if (!lastEndDate || [eventView.event.endDate compare:lastEndDate] == NSOrderedAscending) {
                lastEndDate = eventView.event.endDate;
            }
            
            // layout current column setup
            if (columns.count > 0) {
                [self layoutColumns:columns width:width displayedHours:hours];
            }
        }
        self.eventViewsLayoutIsValid = YES;
    }
}

- (void)layoutColumns:(NSArray*)columns width:(CGFloat)width displayedHours:(NSArray*)hours
{
    // Shift events to the right so hours can be seen
    CGFloat eventOriginX = self.bounds.origin.x + HOUR_LINE_DOT_INSET + 6.0f;

    NSInteger numGroups = columns.count;
    for (NSInteger i = 0; i < numGroups; i++) {
        NSArray* column = columns[i];
        for (NSInteger j = 0; j < column.count; j++) {
            ECEventView* eventView = column[j];
            CGRect eventViewFrame = CGRectMake(eventOriginX + i * floorf(self.contentSize.width / numGroups),
                                               [eventView verticalPositionInRect:self.durationEventsView.bounds forDate:self.displayDate],
                                               floorf((self.bounds.size.width - HOUR_LINE_DOT_INSET - 6.0f) / numGroups),
                                               [eventView heightInRect:self.durationEventsView.bounds forDate:self.displayDate]);
            eventView.frame = eventViewFrame;
        }
    }
}


// PREDCONDITION
// This test assumes that the left event view precedes the right event view as
// defined by ECEventView's compare method
- (BOOL)eventView:(ECEventView*)left overlapsEventView:(ECEventView*)right
{
    BOOL leftStartsAboveRight = [left.event.startDate compare:right.event.endDate] == NSOrderedAscending;
    BOOL rightStartsAboveLeft = [left.event.endDate compare:right.event.startDate] == NSOrderedAscending;
    
    return leftStartsAboveRight || rightStartsAboveLeft;
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
@end
