//
//  ECDateView.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateView.h"
#import "UIView+ECAdditions.h"
#import "NSDateFormatter+ECAdditions.h"
@interface ECDateView()

@property (nonatomic, weak) UILabel* dateLabel;

@end

@implementation ECDateView

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.date = date;
        _selectedDate = NO;
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    
    return self;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self updateLabel];
}

- (BOOL)isTodaysDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    return [calendar isDateInToday:self.date];
}

- (void)setSelectedDate:(BOOL)selectedDate animated:(BOOL)animated
{
    _selectedDate = selectedDate;
    
    [self updateLabel];
    [self setNeedsDisplay];
}

- (UILabel*)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [self addLabel];
        
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _dateLabel;
}

- (void)updateLabel
{
    NSDateFormatter* instance = [NSDateFormatter ecDateViewFormatter];
    NSString* dateString = [instance stringFromDate:self.date];
    
    self.dateLabel.text = dateString;
    if (self.isTodaysDate && !self.isSelectedDate) {
        self.dateLabel.textColor = [UIColor blueColor];
    } else if (self.isSelectedDate) {
        self.dateLabel.textColor = [UIColor whiteColor];
    } else {
        self.dateLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutDateLabel];
}

- (void)layoutDateLabel
{
    DDLogDebug(@"Date Label Frame: %@", NSStringFromCGRect(self.bounds));
    self.dateLabel.frame = self.bounds;
}

#pragma mark - Drawing

#define CIRCLE_RADIUS   20.0f

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.isSelectedDate) {
        [self drawCircle];
    } else {
        [self eraseCircle];
    }
}

- (void)drawCircle
{
    if (self.isTodaysDate) {
        [[UIColor blueColor] setFill];
    } else {
        [[UIColor redColor] setFill];
    }
    
    CGPoint circleCenter = self.dateLabel.center;
    CGRect circleFrame = CGRectMake(circleCenter.x - CIRCLE_RADIUS,
                                    circleCenter.y - CIRCLE_RADIUS,
                                    2 * CIRCLE_RADIUS,
                                    2 * CIRCLE_RADIUS);
    
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:circleFrame];
    
    [circlePath fill];
}

- (void)eraseCircle
{
    [self.backgroundColor setFill];
    
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
}

@end
