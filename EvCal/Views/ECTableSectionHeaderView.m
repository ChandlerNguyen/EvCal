//
//  ECTableSectionHeaderView.m
//  EvCal
//
//  Created by Tom on 7/5/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECTableSectionHeaderView.h"

@implementation ECTableSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawSeparators];
}

const static CGFloat kSeparatorThickness = 0.5;

- (void)drawSeparators
{
    [[UIColor lightGrayColor] setStroke];
    
    CGPoint upperSeparatorOrigin = self.bounds.origin;
    CGPoint upperSeparatorTerminal = CGPointMake(CGRectGetMaxX(self.bounds), upperSeparatorOrigin.y);
    
    CGPoint lowerSeparatorOrigin = CGPointMake(self.bounds.origin.x, CGRectGetMaxY(self.bounds) - kSeparatorThickness);
    CGPoint lowerSeparatorTerminal = CGPointMake(CGRectGetMaxX(self.bounds), lowerSeparatorOrigin.y);
    
    UIBezierPath* upperSeparatorPath = [UIBezierPath bezierPath];
    UIBezierPath* lowerSeparatorPath = [UIBezierPath bezierPath];
    
    upperSeparatorPath.lineWidth = kSeparatorThickness;
    lowerSeparatorPath.lineWidth = kSeparatorThickness;
    
    [upperSeparatorPath moveToPoint:upperSeparatorOrigin];
    [upperSeparatorPath addLineToPoint:upperSeparatorTerminal];
    [upperSeparatorPath stroke];
    
    [lowerSeparatorPath moveToPoint:lowerSeparatorOrigin];
    [lowerSeparatorPath addLineToPoint:lowerSeparatorTerminal];
    [lowerSeparatorPath stroke];
}

@end
