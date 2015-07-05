//
//  ECCalendarCell.m
//  EvCal
//
//  Created by Tom on 6/15/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECCalendarCell.h"

@interface ECCalendarCell()

@property (nonatomic, weak) IBOutlet UILabel* calendarLabel;

@end

@implementation ECCalendarCell

- (void)setCalendar:(EKCalendar *)calendar
{
    _calendar = calendar;
    
    self.calendarLabel.text = calendar.title;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawCalendarDot];
}

static CGFloat kCalendarDotRadius = 4.0f;
static CGFloat kCalendarDotInset = 16.0f;

- (void)drawCalendarDot
{
    if (self.calendar) {
        CGFloat dotCenterY = (self.bounds.size.height - (2 * kCalendarDotRadius)) / 2.0f;
        CGRect dotFrame = CGRectMake(self.bounds.origin.x + kCalendarDotInset, dotCenterY, 2 * kCalendarDotRadius, 2 * kCalendarDotRadius);
        
        [[UIColor colorWithCGColor:self.calendar.CGColor] setFill];
        
        [[UIBezierPath bezierPathWithOvalInRect:dotFrame] fill];
    }
}

@end
