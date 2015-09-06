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

@property (nonatomic, strong) NSArray* dateLabels;

@end

@implementation ECMonthView

#pragma mark - Lifecycle and Properties

- (NSArray*)daysOfMonth
{
    if (!_daysOfMonth) {
        TimeUnit* tunit = [[TimeUnit alloc] init];
        _daysOfMonth = [tunit daysOfMonth:[NSDate date]];
    }
    
    return _daysOfMonth;
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

- (instancetype)initWithDate:(nonnull NSDate *)date frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        TimeUnit* tunit = [[TimeUnit alloc] init];
        _daysOfMonth = [tunit daysOfMonth:date];
    }
    
    return self;
}


#pragma mark - Layout



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
