//
//  ECDateView.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// Helpers
#import "UIView+ECAdditions.h"
#import "UIColor+ECAdditions.h"

// EvCal Classes
#import "ECDateView.h"
#import "NSDateFormatter+ECAdditions.h"
#import "ECCalendarIcon.h"

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

- (void)setEventAccessoryViews:(NSArray *)eventAccessoryViews
{
    if (_eventAccessoryViews) {
        for (ECCalendarIcon* accessoryView in _eventAccessoryViews) {
            [accessoryView removeFromSuperview];
        }
    }
    
    for (ECCalendarIcon* accessoryView in eventAccessoryViews) {
        [self addSubview:accessoryView];
    }
    
    _eventAccessoryViews = eventAccessoryViews;
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
        
        _dateLabel.font = [UIFont systemFontOfSize:19.0f];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _dateLabel;
}

- (UILabel*)weekdayLabel
{
    if (!_weekdayLabel) {
        _weekdayLabel = [self addLabel];
        
        _weekdayLabel.font = [UIFont systemFontOfSize:12.0f];
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
    if (self.isSelectedDate) {
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

#define WEEKDAY_LABEL_HEIGHT        15.0f
#define ACCESSORY_VIEWS_HEIGHT      15.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutWeekdayLabel];
    [self layoutDateLabel];
    [self layoutAccessoryViews];
}

- (void)layoutWeekdayLabel
{
    CGRect weekdayLabelFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, WEEKDAY_LABEL_HEIGHT);
    self.weekdayLabel.frame = weekdayLabelFrame;
}

- (void)layoutDateLabel
{
    CGRect dateLabelFrame = CGRectMake(self.bounds.origin.x,
                                       CGRectGetMaxY(self.weekdayLabel.frame),
                                       self.bounds.size.width,
                                       self.bounds.size.height - WEEKDAY_LABEL_HEIGHT - ACCESSORY_VIEWS_HEIGHT);
    self.dateLabel.frame = dateLabelFrame;
}

#define ACCESSORY_VIEW_WIDTH    8.0f
#define ACCESSORY_VIEW_HEIGHT   8.0f
#define ACCESSORY_VIEW_PADDING  4.0f

- (void)layoutAccessoryViews
{
    CGFloat accessoryViewsWidth = self.eventAccessoryViews.count * ACCESSORY_VIEW_WIDTH + (self.eventAccessoryViews.count - 1) * ACCESSORY_VIEW_PADDING;
    CGFloat accessoryViewsOriginX = floorf(self.bounds.origin.x + (self.bounds.size.width - accessoryViewsWidth) / 2.0f);
    
    CGRect circleFrame = [self circleFrame];
    CGFloat distanceBetweenCircleAndBounds = CGRectGetMaxY(self.bounds) - CGRectGetMaxY(circleFrame);
    CGFloat centeredAccessoryViewOffset = floorf((distanceBetweenCircleAndBounds - ACCESSORY_VIEW_HEIGHT) / 2.0f);
    CGFloat accessoryViewsOriginY = CGRectGetMaxY(circleFrame) + centeredAccessoryViewOffset;
    
    for (NSInteger i = 0; i < self.eventAccessoryViews.count; i++) {
        CGRect accessoryViewFrame = CGRectMake(accessoryViewsOriginX + i * (ACCESSORY_VIEW_PADDING + ACCESSORY_VIEW_WIDTH),
                                               accessoryViewsOriginY,
                                               ACCESSORY_VIEW_WIDTH,
                                               ACCESSORY_VIEW_HEIGHT);
        
        ECCalendarIcon* accessoryView = self.eventAccessoryViews[i];
        accessoryView.frame = accessoryViewFrame;
    }
}

#pragma mark - Drawing

#define CIRCLE_RADIUS   21.0f

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
        [[UIColor ecGreenColor] setFill];
    } else {
        [[UIColor ecPurpleColor] setFill];
    }
    
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:[self circleFrame]];
    
    [circlePath fill];
}

- (CGRect)circleFrame
{
    CGFloat circleRadius = ceilf(.35 * self.bounds.size.width);
    CGPoint circleCenter = self.dateLabel.center;
    CGRect circleFrame = CGRectMake(circleCenter.x - circleRadius,
                                    circleCenter.y - circleRadius,
                                    2 * circleRadius,
                                    2 * circleRadius);
    
    return circleFrame;
}

- (void)eraseCircle
{
    [self.backgroundColor setFill];
    
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
}

@end
