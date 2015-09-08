//
//  ECMonthView.m
//  EvCal
//
//  Created by Tom on 9/4/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import Tunits;
#import "NSDateFormatter+ECAdditions.h"
#import "ECMonthView.h"

@interface ECMonthView()

@property (nonatomic, strong) NSArray* weekdayLabels;
@property (nonatomic, strong) NSArray* dateLabels;

@end

@implementation ECMonthView

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(nonnull NSDate *)date frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        TimeUnit* tunit = [[TimeUnit alloc] init];
        _daysOfMonth = [tunit daysOfMonth:date];
    }
    
    return self;
}

- (instancetype)initWithDate:(nonnull NSDate *)date
{
    return [self initWithDate:date frame:CGRectZero];
}

- (NSArray*)daysOfMonth
{
    if (!_daysOfMonth) {
        TimeUnit* tunit = [[TimeUnit alloc] init];
        _daysOfMonth = [tunit daysOfMonth:[NSDate date]];
    }
    
    return _daysOfMonth;
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
    for (NSString* weekdaySymbol in [NSCalendar currentCalendar].shortWeekdaySymbols) {
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
        
        dateLabel.text = [dateFormatter stringFromDate:date];
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateLabelTapped:)];
        [dateLabel addGestureRecognizer:tapRecognizer];
        
        [self addSubview:dateLabel];
        [dateLabels addObject:dateLabel];
    }
    
    return [dateLabels copy];
}



#pragma mark - Layout

const static NSInteger kCalendarMaximumRows =   7;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutWeekdayLabels];
    [self layoutDateLabels];
}

- (void)layoutWeekdayLabels
{
    if (self.weekdayLabels.count > 0) {
        CGFloat horizontalOffset = 0.0f;
        CGFloat labelWidth = self.bounds.size.width / self.weekdayLabels.count;
        CGFloat labelHeight = self.bounds.size.height / kCalendarMaximumRows;
        
        for (UILabel* weekdayLabel in self.weekdayLabels) {
            CGRect weekdayLabelFrame = CGRectMake(self.bounds.origin.x + horizontalOffset,
                                                  self.bounds.origin.y,
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
        NSInteger firstWeekdayOfMonth = [[NSCalendar currentCalendar] component:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
        
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

- (void)dateLabelTapped:(UITapGestureRecognizer*)sender
{
    NSInteger dateIndex = [self.dateLabels indexOfObject:sender.view];
    NSDate* date = self.daysOfMonth[dateIndex];
    
    self.selectedDate = date;
    [self informDelegateDateWasSelected:date];
}

- (void)informDelegateDateWasSelected:(NSDate*)date
{
    if ([self.monthViewDelegate respondsToSelector:@selector(monthView:didSelectDate:)]) {
        [self.monthViewDelegate monthView:self didSelectDate:date];
    }
}

@end
