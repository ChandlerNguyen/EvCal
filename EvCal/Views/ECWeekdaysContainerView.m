//
//  ECWeekdaysContainerView.m
//  EvCal
//
//  Created by Tom on 6/20/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateView.h"
#import "ECWeekdaysContainerView.h"

@interface ECWeekdaysContainerView()

@end

@implementation ECWeekdaysContainerView

#pragma mark - Properties and Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)setDateViews:(NSArray *)dateViews
{
    if (_dateViews) {
        for (ECDateView* dateView in _dateViews) {
            [dateView removeFromSuperview];
        }
        
        for (ECDateView* dateView in dateViews) {
            [self addSubview:dateView];
        }
    }
    
    _dateViews = dateViews;
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    DDLogDebug(@"Selected date changed to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:selectedDate]);
    _selectedDate = selectedDate;
    
    [self updateSelecteDateView:selectedDate];
}


#pragma mark - Managing selected date view

- (void)updateSelecteDateView:(NSDate*)selectedDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    for (ECDateView* dateView in self.dateViews) {
        if ([calendar isDate:dateView.date inSameDayAsDate:selectedDate]) {
            [dateView setSelectedDate:YES animated:YES];
        } else {
            [dateView setSelectedDate:NO animated:YES];
        }
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutDateViews];
}

#define DATE_VIEW_SPACING   1.0f

- (void)layoutDateViews
{
    if (self.dateViews.count > 0) {
        CGFloat dateViewWidth = floorf(self.bounds.size.width / self.dateViews.count);
        CGFloat leftPadding = (self.bounds.size.width - dateViewWidth * self.dateViews.count) / 2.0f;
        CGFloat paddedOriginX = self.bounds.origin.x + leftPadding;
        for (NSInteger i = 0; i < self.dateViews.count; i++) {
            CGRect dateViewFrame = CGRectMake(paddedOriginX + (i + 1) * (dateViewWidth + DATE_VIEW_SPACING) - dateViewWidth,
                                              self.bounds.origin.y,
                                              dateViewWidth,
                                              self.bounds.size.height - 1.0f);
            
            ECDateView* dateView = self.dateViews[i];
            dateView.frame = dateViewFrame;
        }
    }
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (!CGRectEqualToRect(rect, CGRectZero)) {
        [self drawSeparatorLine];
    }
}

static CGFloat kSeparatorLineWidth = 0.5f;

- (void)drawSeparatorLine
{
    [[UIColor lightGrayColor] setStroke];
    
    CGPoint lineOrigin = CGPointMake(self.bounds.origin.x, CGRectGetMaxY(self.bounds) - kSeparatorLineWidth);
    CGPoint lineTerminal = CGPointMake(CGRectGetMaxX(self.bounds), lineOrigin.y);
    
    UIBezierPath* linePath = [UIBezierPath bezierPath];
    linePath.lineWidth = kSeparatorLineWidth;
    [linePath moveToPoint:lineOrigin];
    [linePath addLineToPoint:lineTerminal];
    
    [linePath stroke];
}
@end
