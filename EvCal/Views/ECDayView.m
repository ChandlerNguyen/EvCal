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

@interface ECDayView()

@property (nonatomic, strong, readwrite) NSMutableArray* eventViews;
@property (nonatomic, strong) NSMutableDictionary* eventViewFrames;

@end

@implementation ECDayView

#pragma mark - Lifecycle and Properties

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
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

- (void)setDisplayDate:(NSDate *)displayDate
{
    _displayDate = displayDate;
    
    [self setNeedsLayout];
}

#pragma mark - Layout

#define EVENT_VIEW_HEIGHT       44.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutEventViews];
}

- (void)layoutEventViews
{
    CGFloat width = self.bounds.size.width;
    NSDate* lastEndDate = nil;
    
    NSArray* hours = [self.displayDate hoursOfDay];
    
    self.eventViews = [self.eventViews sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray* columns = [[NSMutableArray alloc] init];
    
    for (ECEventView* eventView in self.eventViews) {
        if (lastEndDate && [eventView.event.startDate compare:lastEndDate] == NSOrderedDescending) {
            [self layoutColumns:columns width:width displayedHours:hours];
            columns = [@[] mutableCopy];
            lastEndDate = nil;
        }
        
        BOOL placed = NO;
        for (NSInteger i = 0; i < columns.count; i++) {
            NSArray* column = columns[i];
            if (![self eventView:eventView overlapsEventView:[column lastObject]]) {
                columns[i] = [column arrayByAddingObject:eventView];
                placed = YES;
                break;
            }
        }
        
        if (!placed) {
            [columns addObject:@[eventView]];
        }
        
        if (!lastEndDate || [eventView.event.endDate compare:lastEndDate] == NSOrderedAscending) {
            lastEndDate = eventView.event.endDate;
        }
        
        if (columns.count > 0) {
            [self layoutColumns:columns width:width displayedHours:hours];
        }
    }
}

- (void)layoutColumns:(NSArray*)columns width:(CGFloat)width displayedHours:(NSArray*)hours
{
    CGRect contentRect = CGRectMake(self.bounds.origin.x,
                                    self.bounds.origin.y - self.contentOffset.y,
                                    self.contentSize.width,
                                    self.contentSize.height);
    NSInteger numGroups = columns.count;
    for (NSInteger i = 0; i < numGroups; i++) {
        NSArray* column = columns[i];
        for (NSInteger j = 0; j < column.count; j++) {
            ECEventView* eventView = column[j];
            CGRect eventViewFrame = CGRectMake(self.bounds.origin.x + i * floorf(self.contentSize.width / numGroups),
                                               [eventView verticalPositionInRect:contentRect forDate:self.displayDate],
                                               floorf(self.bounds.size.width / numGroups),
                                               [eventView heightInRect:contentRect forDate:self.displayDate]);
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

- (void)addEventView:(ECEventView *)eventView
{
    if (eventView) {
        [self addSubview:eventView];
        
        NSMutableArray* mutableEventViews = [self.eventViews mutableCopy];
        [mutableEventViews addObject:eventView];
        self.eventViews = [mutableEventViews copy];
        
        [self setNeedsLayout];
    } else {
        DDLogWarn(@"Adding nil event view to ECDayView");
    }
}

- (void)addEventViews:(NSArray *)eventViews
{
    NSMutableArray* mutableEventViews = [self.eventViews mutableCopy];
    if (eventViews) {
        for (ECEventView* eventView in eventViews) {
            [self addSubview:eventView];
            [mutableEventViews addObject:eventView];
        }
        
        self.eventViews = [mutableEventViews copy];
        
        [self setNeedsLayout];
    } else {
        DDLogWarn(@"Adding nil array of event views to ECDayView");
    }
}

- (void)removeEventView:(ECEventView *)eventView
{
    if (eventView) {
        NSMutableArray* mutableEventViews = [self.eventViews mutableCopy];
        [mutableEventViews removeObject:eventView];
        self.eventViews = [mutableEventViews copy];
        [eventView removeFromSuperview];
        
        [self setNeedsLayout];
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
        
        [self setNeedsLayout];
    } else {
        DDLogWarn(@"Removing nil array of event views from ECDayView");
    }
}

- (void)clearEventViews
{
    [self removeEventViews:self.eventViews];
}
@end
