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

@property (nonatomic, weak) UILabel* weekdayLabel;
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
        self.layer.borderWidth = 0.5f;
    }
    
    return self;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self updateLabels];
}

- (BOOL)isTodaysDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    return [calendar isDateInToday:self.date];
}

- (void)setSelectedDate:(BOOL)selectedDate animated:(BOOL)animated
{
    _selectedDate = selectedDate;
    
    [self updateLabels];
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

- (UILabel*)weekdayLabel
{
    if (!_weekdayLabel) {
        _weekdayLabel = [self addLabel];
        
        _weekdayLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _weekdayLabel;
}

- (void)updateLabels
{
    [self updateDateLabel];
    [self updateWeekdayLabel];
}

- (void)updateDateLabel
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

- (void)updateWeekdayLabel
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:self.date];
    
    self.weekdayLabel.text = calendar.veryShortWeekdaySymbols[weekday - 1]; // weekdays are not 0 based
}

#pragma mark - Layout

#define WEEKDAY_LABEL_HEIGHT    21.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutWeekdayLabel];
    [self layoutDateLabel];
}

- (void)layoutWeekdayLabel
{
    CGRect weekdayLabelFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, WEEKDAY_LABEL_HEIGHT);
    self.weekdayLabel.frame = weekdayLabelFrame;
    
    DDLogDebug(@"Weekday Label Frame: %@", NSStringFromCGRect(weekdayLabelFrame));
}

- (void)layoutDateLabel
{
    CGRect dateLabelFrame = CGRectMake(self.bounds.origin.x,
                                       CGRectGetMaxY(self.weekdayLabel.frame),
                                       self.bounds.size.width,
                                       self.bounds.size.height - WEEKDAY_LABEL_HEIGHT);
    self.dateLabel.frame = dateLabelFrame;
    
    DDLogDebug(@"Date Label Frame: %@", NSStringFromCGRect(dateLabelFrame));

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
