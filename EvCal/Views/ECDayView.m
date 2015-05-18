//
//  ECDayView.m
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// CocoaPods
#import "NSDate+CupertinoYankee.h"

// EvCal Classes
#import "ECDayView.h"
#import "ECEventView.h"

@interface ECDayView()

@property (nonatomic, strong) NSMutableArray* eventViews;

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

- (NSMutableArray*)eventViews
{
    if (!_eventViews) {
        _eventViews = [[NSMutableArray alloc] init];
    }
    
    return _eventViews;
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
    for (int i = 0; i < self.eventViews.count; i++) {
        CGRect eventViewFrame = CGRectMake(self.bounds.origin.x, i * EVENT_VIEW_HEIGHT + [UIApplication sharedApplication].statusBarFrame.size.height, self.bounds.size.width, EVENT_VIEW_HEIGHT);
        
        ECEventView* eventView = self.eventViews[i];
        eventView.frame = eventViewFrame;
    }
}


#pragma mark - Update event views

- (void)addEventView:(ECEventView *)eventView
{
    [self addSubview:eventView];
    [self.eventViews addObject:eventView];
}

- (void)addEventViews:(NSArray *)eventViews
{
    for (ECEventView* eventView in eventViews) {
        [self addEventView:eventView];
    }
}

- (void)removeEventView:(ECEventView *)eventView
{
    [self.eventViews removeObject:eventView];
    [eventView removeFromSuperview];
}

- (void)removeEventViews:(NSArray *)eventViews
{
    for (ECEventView* eventView in eventViews) {
        [self removeEventView:eventView];
    }
}
@end
