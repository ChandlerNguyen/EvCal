//
//  ECWeekdayPicker.m
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECWeekdayPicker.h"
@interface ECWeekdayPicker()

// weekday arrays
@property (nonatomic, strong, readwrite) NSArray* weekdays;
@property (nonatomic, strong) NSArray* leftWeekdays;
@property (nonatomic, strong) NSArray* rightWeekdays;

@end

@implementation ECWeekdayPicker

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setSelectedDate:date animated:YES];
    }
    
    return self;
}

- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated
{
    _selectedDate = selectedDate;
    [self updateWeekdaysWithDate:selectedDate];
    
    [self.pickerDelegate weekdayPicker:self didSelectDate:selectedDate];
}

#pragma mark - Setting Weekdays

- (void)updateWeekdaysWithDate:(NSDate*)date
{
    self.weekdays = [self weekdaysForDate:date];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    self.leftWeekdays = [self weekdaysForDate:[calendar dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:date options:0]];
    self.rightWeekdays = [self weekdaysForDate:[calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:date options:0]];
}

- (NSArray*)weekdaysForDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* startOfWeek;
    
    // grab first day of week containing date
    [calendar rangeOfUnit:NSCalendarUnitWeekday startDate:&startOfWeek interval:nil forDate:date];
    
    DDLogDebug(@"Weekday Picker - Date: %@, First day of week: %@", date, startOfWeek);
    
    NSMutableArray* mutableWeekdays = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 7; i++) {
        NSDate* date = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:startOfWeek options:0];
        
        [mutableWeekdays addObject:date];
    }
    
    return [mutableWeekdays copy];
}

- (void)scrollToWeekContainingDate:(NSDate *)date
{
    NSArray* oldWeekdays = [self.weekdays copy];
    [self updateWeekdaysWithDate:date];
    
    [self.pickerDelegate weekdayPicker:self didScrollFrom:oldWeekdays to:self.weekdays];
}


#pragma mark - UI Events
@end
