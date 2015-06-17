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

@interface ECDayView()

@property (nonatomic, weak) UIScrollView* dayViewContainer;

@property (nonatomic, weak) ECSingleDayView* previousDayView;
@property (nonatomic, weak) ECSingleDayView* currentDayView;
@property (nonatomic, weak) ECSingleDayView* nextDayView;

@end

@implementation ECDayView

#pragma mark - Properties and Lifecycle

- (void)setDisplayDate:(NSDate *)displayDate animated:(BOOL)animated
{
    _displayDate = displayDate;
    self.currentDayView.displayDate = displayDate;
    
    [self refreshCalendarEvents];
}

- (UIScrollView*)dayViewContainer
{
    if (!_dayViewContainer) {
        UIScrollView* dayViewContainer = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        _dayViewContainer = dayViewContainer;
        [self addSubview:dayViewContainer];
        
        [self setupDayViewContainer];
    }
    
    return _dayViewContainer;
}

- (void)setupDayViewContainer
{
    self.dayViewContainer.pagingEnabled = YES;
    self.dayViewContainer.showsHorizontalScrollIndicator = NO;
    self.dayViewContainer.showsVerticalScrollIndicator = NO;
    self.dayViewContainer.contentSize = self.bounds.size;
}

- (ECSingleDayView*)currentDayView
{
    if (!_currentDayView) {
        ECSingleDayView* currentDayView = [[ECSingleDayView alloc] initWithFrame:self.dayViewContainer.bounds];
        
        _currentDayView = currentDayView;
        [self.dayViewContainer addSubview:currentDayView];
    }
    
    return _currentDayView;
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


#pragma mark - Refreshing

- (void)refreshCalendarEvents
{
    NSArray* eventViews = [self.dayViewDataSource dayView:self eventViewsForDate:self.displayDate];
    
    [self.currentDayView clearEventViews];
    [self.currentDayView addEventViews:eventViews];
}


#pragma mark - Scrolling

- (void)scrollToCurrentTime:(BOOL)animated
{
    [self.currentDayView scrollToCurrentTime:animated];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutDayViewContainer];
    [self layoutCurrentDayView];
}

- (void)layoutDayViewContainer
{
    self.dayViewContainer.frame = self.bounds;
}

- (void)layoutCurrentDayView
{
    CGRect currentDayViewFrame = self.dayViewContainer.bounds;
    
    self.currentDayView.frame = currentDayViewFrame;
    self.currentDayView.contentSize = [self getDayViewContentSize];
}

@end
