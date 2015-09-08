//
//  ECSelectedDateHighlightView.m
//  EvCal
//
//  Created by Tom on 9/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECSelectedDateHighlightView.h"

@implementation ECSelectedDateHighlightView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
    _highlightColor = highlightColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.highlightColor) {
        [self drawHighlightCircle];
    }
}

- (void)drawHighlightCircle
{
    CGFloat circleRadius = floorf(MIN(self.bounds.size.width, self.bounds.size.height) / 2);
    
    CGFloat circleHorizontalInset = (self.bounds.size.width - 2 * circleRadius) / 2;
    CGFloat circleVerticalInset = (self.bounds.size.height - 2 * circleRadius) / 2;
    CGPoint circleOrigin = CGPointMake(self.bounds.origin.x + circleHorizontalInset, self.bounds.origin.y + circleVerticalInset);
    CGRect ovalRect = CGRectMake(circleOrigin.x,
                                 circleOrigin.y,
                                 2 * circleRadius,
                                 2 * circleRadius);
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    
    [self.highlightColor setFill];
    [circlePath fill];
}

@end
