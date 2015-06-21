//
//  ECWeekdayPicker.m
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "NSDate+CupertinoYankee.h"
#import "UIView+ECAdditions.h"
#import "ECWeekdayPicker.h"
#import "ECDateView.h"
#import "ECDateViewFactory.h"
#import "ECWeekdaysContainerView.h"
#import "ECInfiniteHorizontalDatePagingView.h"


#define DATE_PICKER_CELL_REUSE_ID   @"DatePickerCell"

@interface ECWeekdayPicker() <UIScrollViewDelegate, ECInfiniteHorizontalDatePagingViewDataSource, ECInfiniteHorizontalDatePagingViewDelegate>

@property (nonatomic, strong, readwrite) NSDate* selectedDate;
@property (nonatomic, strong, readwrite) NSArray* weekdays;

// views
@property (nonatomic, weak) ECWeekdaysContainerView* centerContainer;
@property (nonatomic, weak) ECInfiniteHorizontalDatePagingView* weekdayScroller;

@property (nonatomic, weak) ECDateView* selectedDateView;

@end

@implementation ECWeekdayPicker

#pragma mark - Lifecycle

- (instancetype)initWithDate:(NSDate *)date
{
    DDLogDebug(@"Initializing weekday picker with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setSelectedDate:date animated:YES];
    }
    
    return self;
}


#pragma mark - Properties

#pragma mark Selected Date

- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    
    if (self.weekdays.count > 0 && !CGRectEqualToRect(frame, oldFrame)) {
        self.weekdayScroller.frame = self.bounds;
    }
}

#define CENTER_WEEKDAY_CONTAINER_INDEX  1

- (ECInfiniteHorizontalDatePagingView*)weekdayScroller
{
    if (!_weekdayScroller) {
        NSDate* scrollerDate = [self.weekdays firstObject];
        ECInfiniteHorizontalDatePagingView* weekdayScroller = [[ECInfiniteHorizontalDatePagingView alloc] initWithFrame:self.bounds
                                                                                                                   date:scrollerDate];
        [self setupWeekdayScroller:weekdayScroller];
        
        [self addSubview:weekdayScroller];
        _weekdayScroller = weekdayScroller;
    }
    
    return _weekdayScroller;
}

- (void)setupWeekdayScroller:(ECInfiniteHorizontalDatePagingView*)scroller
{
    scroller.calendarUnit = NSCalendarUnitDay;
    scroller.pageDateDelta = [NSCalendar currentCalendar].weekdaySymbols.count;
    scroller.pageViewDataSource = self;
    scroller.pageViewDelegate = self;
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    DDLogDebug(@"Changing weekday picker selected date from %@ to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:_selectedDate], [[ECLogFormatter logMessageDateFormatter] stringFromDate:selectedDate]);
    _selectedDate = selectedDate;
    
    [self updateSelectedDateView:NO];
}

- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated
{
    DDLogDebug(@"Changing weekday picker selected date from %@ to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:_selectedDate], [[ECLogFormatter logMessageDateFormatter] stringFromDate:selectedDate]);
    _selectedDate = selectedDate;
    
    if (![self weekdays:self.weekdays containDayOfDate:selectedDate]) {
        [self scrollToWeekContainingDate:selectedDate];
        [self updateWeekdaysWithDate:selectedDate];
        [self setNeedsLayout];
    }
    
    [self updateSelectedDateView:animated];
}

- (void)updateSelectedDateView:(BOOL)animated
{
    [self.centerContainer setSelectedDate:self.selectedDate];
}

- (BOOL)weekdays:(NSArray*)weekdays containDayOfDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    for (NSDate* weekday in weekdays) {
        if ([calendar isDate:weekday inSameDayAsDate:date]) {
            return YES;
        }
    }
    
    return false;
}

- (ECWeekdaysContainerView*)centerContainer
{
    if ([self.weekdayScroller.pageView isKindOfClass:[ECWeekdaysContainerView class]]) {
        return (ECWeekdaysContainerView*)self.weekdayScroller.pageView;
    } else {
        return nil;
    }
}


#pragma mark - Setting Weekdays

- (void)updateWeekdaysWithDate:(NSDate*)date
{
    DDLogDebug(@"Updating weekdays with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    self.weekdays = [self weekdaysForDate:date];
}

- (NSArray*)weekdaysForDate:(NSDate*)date
{
    NSDate* startOfWeek = [date beginningOfWeek];
    
    DDLogDebug(@"Weekday Picker - Date: %@, First day of week: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date], [[ECLogFormatter logMessageDateFormatter] stringFromDate:startOfWeek]);
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSMutableArray* mutableWeekdays = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 7; i++) {
        NSDate* date = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:startOfWeek options:0];
        
        [mutableWeekdays addObject:date];
    }
    
    return [mutableWeekdays copy];
}

- (void)scrollToWeekContainingDate:(NSDate *)date
{
    DDLogDebug(@"Scrolling to week containing date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    NSArray* oldWeekdays = [self.weekdays copy];
    [self updateWeekdaysWithDate:date]; // alters current weekdays
    NSArray* newWeekdays = [self.weekdays copy];
    
    [self.weekdayScroller scrollToDate:[self.weekdays firstObject] animated:YES];
    
    [self informDelegatePickerScrolledFrom:oldWeekdays to:newWeekdays];
}


#pragma mark - UI Events

- (void)refreshWeekdays
{
    [self.weekdayScroller refreshPages];
}

- (void)dateViewTapped:(ECDateView*)dateView
{
    DDLogDebug(@"Date view tapped");
    if (!dateView.isSelectedDate) {
        [self setSelectedDate:dateView.date animated:YES];
        [self informDelegateSelectedDateChanged:dateView.date];
    }
}

- (void)selectDateView:(ECDateView*)dateView animated:(BOOL)animated
{
    self.selectedDateView = dateView;
    [dateView setSelectedDate:YES animated:animated];
}


+ (void)updateDateViews:(NSArray*)dateViews withDates:(NSArray*)dates
{
    for (NSInteger i = 0; i < dateViews.count; i++) {
        ECDateView* dateView = dateViews[i];
        NSDate* date = dates[i];
        dateView.date = date;
    }
}

#pragma mark - Delegate and data source

- (UIView*)pageViewForInfiniteDateView:(ECInfiniteHorizontalDatePagingView *)idv
{
    ECWeekdaysContainerView* containerView = [[ECWeekdaysContainerView alloc] init];
    return containerView;
}

- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView *)idv preparePage:(UIView *)page forDate:(NSDate *)date
{
    DDLogDebug(@"Infinite day view requested page for date: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    if ([page isKindOfClass:[ECWeekdaysContainerView class]]) {
        ECWeekdaysContainerView* weekdaysContainerView = (ECWeekdaysContainerView*)page;
        NSArray* weekdays = [self weekdaysForDate:date];
        
        ECDateViewFactory* dateViewFactory = [[ECDateViewFactory alloc] init];
        NSArray* dateViews = [dateViewFactory dateViewsForDates:weekdays reusingViews:weekdaysContainerView.dateViews];
        
        for (ECDateView* dateView in dateViews) {
            [dateView addTarget:self action:@selector(dateViewTapped:) forControlEvents:UIControlEventTouchUpInside];
            dateView.eventAccessoryViews = [dateViewFactory calendarIconsForCalendars:[self.pickerDataSource calendarsForDate:dateView.date]
                                                                         reusingViews:dateView.eventAccessoryViews];
        }
        
        weekdaysContainerView.dateViews = dateViews;
    }
}

- (void)informDelegateSelectedDateChanged:(NSDate*)selectedDate
{
    if ([self.pickerDelegate respondsToSelector:@selector(weekdayPicker:didSelectDate:)]) {
        [self.pickerDelegate weekdayPicker:self didSelectDate:selectedDate];
    }
}

- (void)informDelegatePickerScrolledFrom:(NSArray*)oldWeekdays to:(NSArray*)newWeekdays
{
    if ([self.pickerDelegate respondsToSelector:@selector(weekdayPicker:didScrollFrom:to:)]) {
        [self.pickerDelegate weekdayPicker:self didScrollFrom:oldWeekdays to:newWeekdays];
    }
}
@end
