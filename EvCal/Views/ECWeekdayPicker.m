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
#import "ECWeekdaysContainerView.h"
#import "ECInfiniteDatePagingView.h"


#define DATE_PICKER_CELL_REUSE_ID   @"DatePickerCell"

@interface ECWeekdayPicker() <ECInfiniteDatePagingViewDataSource, ECInfiniteDatePagingViewDelegate>

// views
@property (nonatomic, weak, readonly) ECWeekdaysContainerView* centerContainer;
@property (nonatomic, weak) ECInfiniteDatePagingView* weekdayScroller;

//@property (nonatomic, weak) ECDateView* selectedDateView;

@end

@implementation ECWeekdayPicker

#pragma mark - Lifecycle

- (instancetype)initWithDate:(NSDate *)date
{
    DDLogDebug(@"Initializing weekday picker with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initWeekdayScrollerWithDate:date];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    
    if (self.weekdays.count > 0 && !CGRectEqualToRect(frame, oldFrame)) {
        self.weekdayScroller.frame = self.bounds;
    }
}

- (void)initWeekdayScrollerWithDate:(NSDate*)date
{
    DDLogDebug(@"Creating weekday scroller with initial date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    ECInfiniteDatePagingView* weekdayScroller = [[ECInfiniteDatePagingView alloc] initWithFrame:self.bounds
                                                                                           date:date];
    [self setupWeekdayScroller:weekdayScroller];

    [self addSubview:weekdayScroller];
    _weekdayScroller = weekdayScroller;
}

- (void)setupWeekdayScroller:(ECInfiniteDatePagingView*)scroller
{
    scroller.calendarUnit = NSCalendarUnitDay;
    scroller.pageDateDelta = [NSCalendar currentCalendar].weekdaySymbols.count;
    scroller.pageViewDataSource = self;
    scroller.pageViewDelegate = self;
}

- (ECWeekdaysContainerView*)centerContainer
{
    ECDatePage* visiblePage = self.weekdayScroller.visiblePage;
    if ([visiblePage isKindOfClass:[ECWeekdaysContainerView class]]) {
        return (ECWeekdaysContainerView*)visiblePage;
    } else {
        return nil;
    }
}

- (NSArray*)weekdays
{
    return self.centerContainer.weekdays;
}

@synthesize selectedDate = _selectedDate;

- (NSDate*)selectedDate
{
    if (!_selectedDate) {
        _selectedDate = [[NSDate date] beginningOfDay];
    }
    
    return _selectedDate;
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    
    if (![self weekdays:self.centerContainer.weekdays containDayOfDate:selectedDate]) {
        [self scrollToWeekContainingDate:selectedDate];
    } else {
        self.centerContainer.selectedDate = selectedDate;
    }
    
    [self informDelegateDateWasSelected:selectedDate];
}

#pragma mark - Date math

- (BOOL)weekdays:(NSArray*)weekdays containDayOfDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    for (NSDate* weekday in weekdays) {
        if ([calendar isDate:weekday inSameDayAsDate:date]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - ECInfiniteDatePagingView Data source and delegate

- (ECDatePage*)pageViewForInfiniteDateView:(ECInfiniteDatePagingView *)idv
{
    ECWeekdaysContainerView* pageView = [[ECWeekdaysContainerView alloc] initWithFrame:self.bounds];
    return pageView;
}


- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv preparePage:(ECDatePage *)page
{
    if ([page isKindOfClass:[ECWeekdaysContainerView class]]) {
        ECWeekdaysContainerView* weekdayContainer = (ECWeekdaysContainerView*)page;
        
        for (ECDateView* dateView in weekdayContainer.dateViews) {
            dateView.calendars = [self.pickerDataSource calendarsForDate:dateView.date];
            [dateView addTarget:self action:@selector(dateViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv didChangeVisiblePage:(ECDatePage *)page
{
    if ([page isKindOfClass:[ECWeekdaysContainerView class]]) {
        ECWeekdaysContainerView* weekdayContainerView = (ECWeekdaysContainerView*)page;
        if ([self weekdays:weekdayContainerView.weekdays containDayOfDate:self.selectedDate]) {
            weekdayContainerView.selectedDate = self.selectedDate;
        } else {
            weekdayContainerView.selectedDate = [self selectedDateForWeekdays:weekdayContainerView.weekdays];
            self.selectedDate = weekdayContainerView.selectedDate;
        }
    }
}

- (NSDate*)selectedDateForWeekdays:(NSArray*)weekdays
{
    NSDate* selectedDate = nil;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    for (NSDate* date in weekdays) {
        if ([calendar isDateInToday:date]) {
            selectedDate = date;
        }
    }
    
    if (!selectedDate) {
        NSInteger weekdayIndex = [calendar components:(NSCalendarUnitWeekday) fromDate:self.selectedDate].weekday - 1;
        selectedDate = weekdays[weekdayIndex];
    }
    
    return selectedDate;
}

- (void)informDelegateDateWasSelected:(NSDate*)date
{
    if ([self.pickerDelegate respondsToSelector:@selector(weekdayPicker:didSelectDate:)]) {
        [self.pickerDelegate weekdayPicker:self didSelectDate:date];
    }
}

- (void)scrollToWeekContainingDate:(NSDate *)date
{
    DDLogDebug(@"Scrolling to week containing date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    [self.weekdayScroller scrollToDate:[date beginningOfWeek] animated:YES];
}


#pragma mark - UI Events

- (void)dateViewTapped:(ECDateView*)dateView
{
    self.selectedDate = dateView.date;
}

- (void)refreshWeekdays
{
    DDLogDebug(@"Refreshing weekdays");
    [self.weekdayScroller refreshPages];
}

- (void)refreshWeekdayWithDate:(NSDate *)date
{
    DDLogDebug(@"Refreshing weekday with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    [self.weekdayScroller refreshPages];
}

//
//
//#pragma mark - Properties
//
//#pragma mark Selected Date
//
//
//- (ECInfiniteDatePagingView*)weekdayScroller
//{
//    if (!_weekdayScroller) {
//    }
//    
//    return _weekdayScroller;
//}
//
//
//- (void)setSelectedDate:(NSDate *)selectedDate
//{
//    DDLogDebug(@"Changing weekday picker selected date from %@ to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:_selectedDate], [[ECLogFormatter logMessageDateFormatter] stringFromDate:selectedDate]);
//    _selectedDate = selectedDate;
//    
//    [self updateSelectedDateView:NO];
//    [self informDelegateSelectedDateChanged:selectedDate];
//}
//
//- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated
//{
//    DDLogDebug(@"Changing weekday picker selected date from %@ to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:_selectedDate], [[ECLogFormatter logMessageDateFormatter] stringFromDate:selectedDate]);
//    _selectedDate = selectedDate;
//    
//    if (![self weekdays:self.weekdays containDayOfDate:selectedDate]) {
//        [self scrollToWeekContainingDate:selectedDate];
//        [self updateWeekdaysWithDate:selectedDate];
//        [self setNeedsLayout];
//    }
//    
//    [self updateSelectedDateView:animated];
//    [self informDelegateSelectedDateChanged:selectedDate];
//}
//
//- (void)updateSelectedDateView:(BOOL)animated
//{
//    DDLogDebug(@"Updating selected date view with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:self.selectedDate]);
//    [self.centerContainer setSelectedDate:self.selectedDate];
//}
//
//- (BOOL)weekdays:(NSArray*)weekdays containDayOfDate:(NSDate*)date
//{
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    for (NSDate* weekday in weekdays) {
//        if ([calendar isDate:weekday inSameDayAsDate:date]) {
//            return YES;
//        }
//    }
//    
//    return false;
//}
//
//- (ECWeekdaysContainerView*)centerContainer
//{
//    if ([self.weekdayScroller.visiblePage isKindOfClass:[ECWeekdaysContainerView class]]) {
//        return (ECWeekdaysContainerView*)self.weekdayScroller.visiblePage;
//    } else {
//        return nil;
//    }
//}
//
//
//#pragma mark - Setting Weekdays
//
//- (void)updateWeekdaysWithDate:(NSDate*)date
//{
//    DDLogDebug(@"Updating weekdays with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
//    self.weekdays = [self weekdaysForDate:date];
//}
//
//- (NSArray*)weekdaysForDate:(NSDate*)date
//{
//    NSDate* startOfWeek = [date beginningOfWeek];
//    
//    DDLogDebug(@"Weekday Picker - Date: %@, First day of week: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date], [[ECLogFormatter logMessageDateFormatter] stringFromDate:startOfWeek]);
//    
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    NSMutableArray* mutableWeekdays = [[NSMutableArray alloc] init];
//    for (NSUInteger i = 0; i < 7; i++) {
//        NSDate* date = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:startOfWeek options:0];
//        
//        [mutableWeekdays addObject:date];
//    }
//    
//    return [mutableWeekdays copy];
//}
//
//
//- (void)dateViewTapped:(ECDateView*)dateView
//{
//    DDLogDebug(@"Date view tapped");
//    if (!dateView.isSelectedDate) {
//        [self setSelectedDate:dateView.date animated:YES];
//        [self updateSelectedDateView:YES];
//        [self informDelegateSelectedDateChanged:dateView.date];
//    }
//}
//
//- (void)selectDateView:(ECDateView*)dateView animated:(BOOL)animated
//{
//    DDLogDebug(@"Selecting date view with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:dateView.date]);
//    self.selectedDateView = dateView;
//    [self updateSelectedDateView:YES];
//    [dateView setSelectedDate:YES animated:animated];
//}
//
//
//+ (void)updateDateViews:(NSArray*)dateViews withDates:(NSArray*)dates
//{
//    DDLogDebug(@"Updating date views with dates:");
//    for (NSDate* date in dates) {
//        DDLogDebug(@"\t%@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
//    }
//    for (NSInteger i = 0; i < dateViews.count; i++) {
//        ECDateView* dateView = dateViews[i];
//        NSDate* date = dates[i];
//        dateView.date = date;
//    }
//}
//
//#pragma mark - Delegate and data source
//
//- (UIView*)pageViewForInfiniteDateView:(ECInfiniteDatePagingView *)idv
//{
//    DDLogDebug(@"Creating base page view for infinite scroller");
//    ECWeekdaysContainerView* containerView = [[ECWeekdaysContainerView alloc] init];
//    return containerView;
//}
//
//- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv preparePage:(ECDatePage*)page
//{
//    if ([page isKindOfClass:[ECWeekdaysContainerView class]]) {
//        DDLogDebug(@"Preparing date view with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:page.date]);
//        ECWeekdaysContainerView* weekdaysContainerView = (ECWeekdaysContainerView*)page;
//        NSArray* weekdays = [self weekdaysForDate:weekdaysContainerView.date];
//        
//        ECDateViewFactory* dateViewFactory = [[ECDateViewFactory alloc] init];
//        NSArray* dateViews = [dateViewFactory dateViewsForDates:weekdays reusingViews:weekdaysContainerView.dateViews];
//        
//        for (ECDateView* dateView in dateViews) {
//            [dateView addTarget:self action:@selector(dateViewTapped:) forControlEvents:UIControlEventTouchUpInside];
//            dateView.calendars = [self.pickerDataSource calendarsForDate:dateView.date];
//        }
//        
//        weekdaysContainerView.dateViews = dateViews;
//    }
//}
//
//- (void)infiniteDateView:(ECInfiniteDatePagingView *)idv dateChangedFrom:(NSDate *)fromDate to:(NSDate *)toDate
//{
//    DDLogDebug(@"Infinite date view changed date from %@ to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:fromDate], [[ECLogFormatter logMessageDateFormatter] stringFromDate:toDate]);
//    self.selectedDate = toDate;
//}
//
//- (void)informDelegateSelectedDateChanged:(NSDate*)selectedDate
//{
//    DDLogDebug(@"Informing delegate seleted date changed to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:selectedDate]);
//    if ([self.pickerDelegate respondsToSelector:@selector(weekdayPicker:didSelectDate:)]) {
//        [self.pickerDelegate weekdayPicker:self didSelectDate:selectedDate];
//    }
//}

@end
