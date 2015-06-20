//
//  ECWeekdaysContainerView.m
//  EvCal
//
//  Created by Tom on 6/20/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateView.h"
#import "ECWeekdaysContainerView.h"

@implementation ECWeekdaysContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    return self;
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
        for (NSInteger i = 0; i < self.dateViews.count; i++) {
            CGRect dateViewFrame = CGRectMake(self.bounds.origin.x + (i + 1) * (dateViewWidth + DATE_VIEW_SPACING) - DATE_VIEW_SPACING,
                                              self.bounds.origin.y,
                                              dateViewWidth,
                                              self.bounds.size.height);
            
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
        [self drawDateViewOutlines];
    }
}

- (void)drawDateViewOutlines
{
    if (self.dateViews.count > 0) {
        [[UIColor lightGrayColor] setStroke];
        UIBezierPath* linePath = [UIBezierPath bezierPath];
        
        CGFloat pageWidth = self.bounds.size.width / self.dateViews.count;
        CGFloat boundsMaxY = CGRectGetMaxY(self.bounds);
        for (NSInteger i = 0; i < self.dateViews.count - 1; i++) {
            CGPoint lineOrigin = CGPointMake(self.bounds.origin.x + (i + 1) * (pageWidth + 1), self.bounds.origin.y);
            CGPoint lineTerminal = CGPointMake(lineOrigin.x, boundsMaxY);

            [linePath moveToPoint:lineOrigin];
            [linePath addLineToPoint:lineTerminal];
        }
        
        [linePath stroke];
    }
}

@end
