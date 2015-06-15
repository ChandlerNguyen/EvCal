//
//  ECCalendarCell.m
//  EvCal
//
//  Created by Tom on 6/15/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECCalendarCell.h"
#import "ECDateViewAccessoryView.h"
@interface ECCalendarCell()

@property (nonatomic, weak) IBOutlet UILabel* calendarLabel;
@property (nonatomic, weak) IBOutlet ECDateViewAccessoryView* calendarAccessory;

@end

@implementation ECCalendarCell

- (void)setCalendar:(EKCalendar *)calendar
{
    _calendar = calendar;
    
    self.calendarLabel.text = calendar.title;
    self.calendarAccessory.calendarColor = [UIColor colorWithCGColor:calendar.CGColor];
}

@end
