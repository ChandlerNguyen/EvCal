//
//  ECDateView.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateView.h"

@implementation ECDateView

- (BOOL)isTodaysDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    return [calendar isDateInToday:self.date];
}

- (void)setSelectedDate:(BOOL)selectedDate animated:(BOOL)animated
{
    _selectedDate = selectedDate;
}

@end
