//
//  ECDateView.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
@import EventKit;
@import QuartzCore;

// Helpers
#import "UIView+ECAdditions.h"
#import "UIColor+ECAdditions.h"

// EvCal Classes
#import "ECDateView.h"
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
    BOOL oldSelectedDate = self.isSelectedDate;
    _selectedDate = selectedDate;
    
    if (oldSelectedDate != selectedDate) {
        [self updateLabels];
        [self setNeedsDisplay];
    }
    
    if (selectedDate) {
        self.layer.shadowOpacity = 0.25f;
        //self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        self.layer.shadowRadius = 2.0f;
    } else {
        self.layer.shadowRadius = 0.0f;
    }
}

- (void)setCalendars:(NSArray *)calendars
{
    BOOL calendarsChanged = ![_calendars isEqualToArray:calendars];
    
    _calendars = calendars;

    if (calendarsChanged) {
        [self setNeedsDisplay];
    }
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

#pragma mark - Drawing

#define CIRCLE_RADIUS   21.0f

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.isSelectedDate) {
        [self drawCircle];
    }
    
    if (self.calendars.count > 0) {
        [self drawCalendarDots];
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
    CGFloat circleRadius = ceilf(.30 * self.bounds.size.width);
    CGPoint circleCenter = self.dateLabel.center;
    CGRect circleFrame = CGRectMake(circleCenter.x - circleRadius,
                                    circleCenter.y - circleRadius,
                                    2 * circleRadius,
                                    2 * circleRadius);
    
    return circleFrame;
}

#define ACCESSORY_VIEW_WIDTH    8.0f
#define ACCESSORY_VIEW_HEIGHT   8.0f
#define ACCESSORY_VIEW_PADDING  4.0f

- (void)drawCalendarDots
{
    if (self.calendars.count > 0) {
        CGFloat accessoryViewsWidth = self.calendars.count * ACCESSORY_VIEW_WIDTH + (self.calendars.count - 1) * ACCESSORY_VIEW_PADDING;
        CGFloat accessoryViewsOriginX = floorf(self.bounds.origin.x + (self.bounds.size.width - accessoryViewsWidth) / 2.0f);

        CGRect circleFrame = [self circleFrame];
        CGFloat distanceBetweenCircleAndBounds = CGRectGetMaxY(self.bounds) - CGRectGetMaxY(circleFrame);
        CGFloat centeredAccessoryViewOffset = floorf((distanceBetweenCircleAndBounds - ACCESSORY_VIEW_HEIGHT) / 2.0f);
        CGFloat accessoryViewsOriginY = CGRectGetMaxY(circleFrame) + centeredAccessoryViewOffset;
        
        for (NSInteger i = 0; i < self.calendars.count; i++) {
            EKCalendar* calendar = self.calendars[i];
            [[UIColor colorWithCGColor:calendar.CGColor] setFill];
            CGRect calendarDotFrame = CGRectMake(accessoryViewsOriginX + i * (ACCESSORY_VIEW_PADDING + ACCESSORY_VIEW_WIDTH),
                                                 accessoryViewsOriginY,
                                                 ACCESSORY_VIEW_WIDTH,
                                                 ACCESSORY_VIEW_HEIGHT);
            UIBezierPath* calendarDotPath = [UIBezierPath bezierPathWithOvalInRect:calendarDotFrame];
            [calendarDotPath fill];
        }
    }
}

@end
