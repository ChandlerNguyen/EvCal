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
        
        self.layer.borderWidth = 1.0f;
    }
    
    return self;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self updateLabelWithDate:date];
}

- (BOOL)isTodaysDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    return [calendar isDateInToday:self.date];
}

- (void)setSelectedDate:(BOOL)selectedDate animated:(BOOL)animated
{
    _selectedDate = selectedDate;
}

- (UILabel*)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [self addLabel];
        
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _dateLabel;
}

- (void)updateLabelWithDate:(NSDate*)date
{
    NSDateFormatter* instance = [NSDateFormatter ecDateViewFormatter];
    NSString* dateString = [instance stringFromDate:date];
    
    self.dateLabel.text = dateString;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutDateLabel];
}

- (void)layoutDateLabel
{
    self.dateLabel.frame = self.bounds;
}

@end
