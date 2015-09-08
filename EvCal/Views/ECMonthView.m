//
//  ECMonthView.m
//  EvCal
//
//  Created by Tom on 9/4/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import Tunits;
#import "NSDateFormatter+ECAdditions.h"
#import "UIView+ECAdditions.h"
#import "UIColor+ECAdditions.h"
#import "ECMonthView.h"
#import "ECSelectedDateHighlightView.h"

@interface ECMonthView()

@property (nonatomic, strong) NSCalendar* calendar;

@property (nonatomic, weak) UILabel* monthLabel;
@property (nonatomic, weak) ECSelectedDateHighlightView* selectedDateHighlightView;
@property (nonatomic, strong) NSArray* weekdayLabels;
@property (nonatomic, strong) NSArray* dateLabels;

@end

@implementation ECMonthView

#pragma mark - Constants

const static CGFloat kDefaultDateLabelFontSize =    17.0f;
const static CGFloat kTodaysDateLabelFontSize =     18.0f;
const static CGFloat kMonthLabelFontSize =          19.0f;

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(nonnull NSDate *)date frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        TimeUnit* tunit = [[TimeUnit alloc] init];
        _daysOfMonth = [tunit daysOfMonth:date];
        [self updateMonthLabel];
        [self updateDates];
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(monthViewTapped:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    
    return self;
}

- (instancetype)initWithDate:(nonnull NSDate *)date
{
    return [self initWithDate:date frame:CGRectZero];
}

- (instancetype)initWithSelectedDate:(nonnull NSDate *)selectedDate
{
    self = [self initWithDate:selectedDate];
    if (self) {
        self.selectedDate = selectedDate;
    }
    
    return self;
}

- (NSArray*)daysOfMonth
{
    if (!_daysOfMonth) {
        TimeUnit* tunit = [[TimeUnit alloc] init];
        _daysOfMonth = [tunit daysOfMonth:[NSDate date]];
    }
    
    return _daysOfMonth;
}

- (UILabel*)monthLabel
{
    if (!_monthLabel) {
        _monthLabel = [self addLabel];
        
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        _monthLabel.font = [UIFont boldSystemFontOfSize:kMonthLabelFontSize];
    }
    
    return _monthLabel;
}

- (NSArray*)weekdayLabels
{
    if (!_weekdayLabels) {
        _weekdayLabels = [self createWeekdayLabels];
    }
    
    return _weekdayLabels;
}

- (NSArray*)createWeekdayLabels
{
    NSMutableArray* weekdayLabels = [[NSMutableArray alloc] init];
    for (NSString* weekdaySymbol in self.calendar.shortWeekdaySymbols) {
        UILabel* weekdayLabel = [[UILabel alloc] init];
        
        weekdayLabel.text = weekdaySymbol;
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:weekdayLabel];
        [weekdayLabels addObject:weekdayLabel];
    }
    
    return [weekdayLabels copy];
}

- (NSArray*)dateLabels
{
    if (!_dateLabels) {
        _dateLabels = [self createDateLabels];
    }
    
    return _dateLabels;
}

- (NSArray*)createDateLabels
{
    NSMutableArray* dateLabels = [[NSMutableArray alloc] init];
    
    NSDateFormatter* dateFormatter = [NSDateFormatter ecDateViewFormatter];
    for (NSDate* date in self.daysOfMonth) {
        UILabel* dateLabel = [[UILabel alloc] init];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        
        dateLabel.text = [dateFormatter stringFromDate:date];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.opaque = NO;
        
        [self addSubview:dateLabel];
        [dateLabels addObject:dateLabel];
    }
    
    return [dateLabels copy];
}

- (void)setSelectedDate:(NSDate * __nullable)selectedDate
{
    _selectedDate = selectedDate;
    [self updateLabelHighlights];
}

- (ECSelectedDateHighlightView*)selectedDateHighlightView
{
    if (!_selectedDateHighlightView) {
        ECSelectedDateHighlightView* selectedDateHighlightView = [[ECSelectedDateHighlightView alloc] init];
        selectedDateHighlightView.highlightColor = [UIColor ecPurpleColor];
        
        UILabel* firstDateLabel = [self.dateLabels firstObject];
        [self insertSubview:selectedDateHighlightView belowSubview:firstDateLabel];
        _selectedDateHighlightView = selectedDateHighlightView;
    }
    
    return _selectedDateHighlightView;
}

- (NSCalendar*)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    
    return _calendar;
}


#pragma mark - Layout
// Month Label, Weekdays Labels, 6 max weeks of dates
const static NSInteger kCalendarMaximumRows =   8;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutMonthLabel];
    [self layoutWeekdayLabels];
    [self layoutDateLabels];
    [self updateLabelHighlights];
}

- (void)layoutMonthLabel
{
    CGFloat labelHeight = ceilf(self.bounds.size.height / kCalendarMaximumRows);
    
    CGRect monthLabelFrame = CGRectMake(self.bounds.origin.x,
                                        self.bounds.origin.y,
                                        self.bounds.size.width,
                                        labelHeight);
    
    self.monthLabel.frame = monthLabelFrame;
}

- (void)layoutWeekdayLabels
{
    if (self.weekdayLabels.count > 0) {
        CGFloat vertialOffset = CGRectGetMaxY(self.monthLabel.frame);
        CGFloat horizontalOffset = 0.0f;
        CGFloat labelWidth = ceilf(self.bounds.size.width / self.weekdayLabels.count);
        CGFloat labelHeight = ceilf(self.bounds.size.height / kCalendarMaximumRows);
        
        for (UILabel* weekdayLabel in self.weekdayLabels) {
            CGRect weekdayLabelFrame = CGRectMake(self.bounds.origin.x + horizontalOffset,
                                                  self.bounds.origin.y + vertialOffset,
                                                  labelWidth,
                                                  labelHeight);
            weekdayLabel.frame = weekdayLabelFrame;
            
            horizontalOffset += labelWidth;
        }
    }
}

- (void)layoutDateLabels
{
    if (self.dateLabels.count > 0) {
        UILabel* firstWeekdayLabel = [self.weekdayLabels firstObject];
        CGFloat firstWeekdayLabelMaxY = CGRectGetMaxY(firstWeekdayLabel.frame);
        CGFloat labelWidth = firstWeekdayLabel.frame.size.width;
        CGFloat labelHeight = firstWeekdayLabel.frame.size.height;
        
        NSDate* firstDayOfMonth = [self.daysOfMonth firstObject];
        NSInteger firstWeekdayOfMonth = [self.calendar component:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
        
        for (NSInteger i = 0; i < self.dateLabels.count; i++) {
            UILabel* dateLabel = self.dateLabels[i];
            
            // minus 1 because arrays are 0-based but weekdays are 1-based
            NSInteger row = (i + firstWeekdayOfMonth - 1) / 7;
            NSInteger column = (i + firstWeekdayOfMonth - 1) % 7;
            
            CGFloat dateLabelOriginY = firstWeekdayLabelMaxY + labelHeight * row;
            CGFloat dateLabelOriginX = self.bounds.origin.x + labelWidth * column;
            
            CGRect dateLabelFrame = CGRectMake(dateLabelOriginX,
                                               dateLabelOriginY,
                                               labelWidth,
                                               labelHeight);
            
            dateLabel.frame = dateLabelFrame;
        }
    }
}

#pragma mark - UI Events

- (void)updateMonthLabel
{
    NSDate* firstDayOfMonth = [self.daysOfMonth firstObject];
    self.monthLabel.text = [[NSDateFormatter ecMonthFormatter] stringFromDate:firstDayOfMonth];
}

- (void)updateDates
{
    for (NSInteger i = 0; i < self.dateLabels.count; i++) {
        NSDate* dayOfMonth = self.daysOfMonth[i];
        UILabel* dateLabel = self.dateLabels[i];
        
        if ([self.calendar isDateInToday:dayOfMonth]) {
            dateLabel.font = [UIFont boldSystemFontOfSize:kTodaysDateLabelFontSize];
        } else {
            dateLabel.font = [UIFont systemFontOfSize:kDefaultDateLabelFontSize];
        }
    }
    
    [self updateLabelHighlights];
}

- (void)updateLabelHighlights
{
    for (NSInteger i = 0; i < self.dateLabels.count; i++) {
        NSDate* dayOfMonth = self.daysOfMonth[i];
        UILabel* dateLabel = self.dateLabels[i];
        if (self.selectedDate && [self.calendar isDate:dayOfMonth inSameDayAsDate:self.selectedDate]) {
            [self highlightDateLabel:dateLabel date:dayOfMonth];
        } else {
            dateLabel.textColor = [self.calendar isDateInToday:dayOfMonth] ? [UIColor ecGreenColor] : [UIColor darkTextColor];
        }
    }
    
    // make selectedDateHighlightView invisible
    if (!self.selectedDate) {
        self.selectedDateHighlightView.frame = CGRectZero;
    }
}

- (void)highlightDateLabel:(UILabel*)dateLabel date:(NSDate*)date
{
    dateLabel.textColor = [UIColor whiteColor];
    self.selectedDateHighlightView.highlightColor = [self.calendar isDateInToday:date] ? [UIColor ecGreenColor] : [UIColor ecPurpleColor];
    self.selectedDateHighlightView.frame = dateLabel.frame;
}

- (void)monthViewTapped:(UITapGestureRecognizer*)sender
{
    NSDate* tappedDate = [self getTappedDate:sender];
    
    if (tappedDate) {
        self.selectedDate = tappedDate;
        [self informDelegateDateWasSelected:tappedDate];
    }
}

- (NSDate*)getTappedDate:(UITapGestureRecognizer*)tapRecognizer
{
    CGPoint tapLocation = [tapRecognizer locationInView:self];
    for (NSInteger i = 0; i < self.dateLabels.count; i++) {
        UILabel* dateLabel = self.dateLabels[i];
        if (CGRectContainsPoint(dateLabel.frame, tapLocation)) {
            NSDate* tappedDate = self.daysOfMonth[i];
            return tappedDate;
        }
    }
    
    return nil;
}

- (void)informDelegateDateWasSelected:(NSDate*)date
{
    if ([self.monthViewDelegate respondsToSelector:@selector(monthView:didSelectDate:)]) {
        [self.monthViewDelegate monthView:self didSelectDate:date];
    }
}

@end
