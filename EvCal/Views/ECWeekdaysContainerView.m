//
//  ECWeekdaysContainerView.m
//  EvCal
//
//  Created by Tom on 6/20/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateView.h"
#import "ECWeekdaysContainerView.h"
#import "ECDateViewFactory.h"
#import "NSdate+CupertinoYankee.h"

@interface ECWeekdaysContainerView()

@property (nonatomic, strong, readwrite) NSArray* weekdays;
@property (nonatomic, strong, readwrite) NSArray* dateViews;

@end

@implementation ECWeekdaysContainerView

#pragma mark - Properties and Lifecycle

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.date = date;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (NSArray*)dateViews
{
    if (!_dateViews) {
        _dateViews = [[[ECDateViewFactory alloc] init] dateViewsForDates:self.weekdays reusingViews:_dateViews];
        
        for (ECDateView* dateView in _dateViews) {
            [self addSubview:dateView];
        }
    }
    return _dateViews;
}

- (void)setDate:(NSDate *)date
{
    [super setDate:date];
    self.weekdays = [self weekdaysForDate:date];
    [self updateDateViewsWithWeekdays:self.weekdays];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    DDLogDebug(@"Selected date changed to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:selectedDate]);
    NSDate* oldSelectedDate = _selectedDate;
    _selectedDate = selectedDate;
   
    if (!oldSelectedDate ||
        ![[NSCalendar currentCalendar] isDate:selectedDate inSameDayAsDate:oldSelectedDate]) {
        [self updateSelecteDateView:selectedDate];
    }
}


- (NSArray*)weekdaysForDate:(NSDate*)date
{
    NSDate* startOfWeek = [date beginningOfWeek];

    DDLogDebug(@"Date: %@, First day of week: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date], [[ECLogFormatter logMessageDateFormatter] stringFromDate:startOfWeek]);

    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSMutableArray* mutableWeekdays = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 7; i++) {
        NSDate* date = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:startOfWeek options:0];

        [mutableWeekdays addObject:date];
    }

    return [mutableWeekdays copy];
}

#pragma mark - Managing date views

- (void)updateSelecteDateView:(NSDate*)selectedDate
{
    DDLogDebug(@"Updating selected date view with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:selectedDate]);
    NSCalendar* calendar = [NSCalendar currentCalendar];
    for (ECDateView* dateView in self.dateViews) {
        if ([calendar isDate:dateView.date inSameDayAsDate:selectedDate]) {
            [dateView setSelectedDate:YES animated:YES];
        } else {
            [dateView setSelectedDate:NO animated:YES];
        }
    }
}

- (void)updateDateViewsWithWeekdays:(NSArray*)weekdays
{
    if (weekdays) {
        for (NSInteger i = 0; i < self.dateViews.count; i++) {
            ECDateView* dateView = self.dateViews[i];
            NSDate* date = weekdays[i];
            dateView.date = date;
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
