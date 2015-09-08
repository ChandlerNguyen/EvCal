//
//  ECSelectedDateHighlightView.m
//  EvCal
//
//  Created by Tom on 9/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECSelectedDateHighlightView.h"

@implementation ECSelectedDateHighlightView

- (void)setHighlightColor:(UIColor *)highlightColor
{
    _highlightColor = highlightColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawHighlightCircle];
}

- (void)drawHighlightCircle
{
    CGFloat circleRadius = floorf(MIN(self.bounds.size.width, self.bounds.size.height) / 2);
    
    CGFloat circleHorizontalInset = self.center.x - circleRadius;
    CGFloat circleVerticalInset = self.center.y - circleRadius;
    CGRect ovalRect = CGRectMake(self.bounds.origin.x + circleHorizontalInset,
                                 self.bounds.origin.y + circleVerticalInset,
                                 2 * circleRadius,
                                 2 * circleRadius);
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    
    [self.highlightColor setFill];
    [circlePath fill];
}

@end
