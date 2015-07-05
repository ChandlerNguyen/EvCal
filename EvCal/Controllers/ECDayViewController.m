//
//  ECDayViewController.m
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;

// CocoaPods
#import "NSDate+CupertinoYankee.h"
#import "NSDate+ECEventAdditions.h"
#import "CocoaLumberjack.h"

// EvCal Classes
#import "ECDayViewController.h"
#import "ECEditEventViewController.h"
#import "ECDayView.h"
#import "ECEventStoreProxy.h"
#import "ECWeekdayPicker.h"

@interface ECDayViewController () <ECDayViewDataSource, ECDayViewDelegate, ECWeekdayPickerDelegate, ECWeekdayPickerDataSource, ECEditEventViewControllerDelegate>

// Buttons
@property (nonatomic, weak) IBOutlet UIBarButtonItem* addEventButton;

// Day view
@property (nonatomic) BOOL userDidScrollDayViewSinceDateChange;
@property (nonatomic, weak) ECDayView* dayView;

// Date picker
@property (nonatomic, weak) ECWeekdayPicker* weekdayPicker;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;

// State

@end

@implementation ECDayViewController

#pragma mark - Lifecycle and Properties

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.dateFormatter stringFromDate:self.displayDate];
    self.navigationController.toolbarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEvents) name:ECEventStoreProxyAuthorizationStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEvents) name:ECEventStoreProxyCalendarChangedNotification object:nil];
    [self refreshEvents];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self layoutWeekdayPicker];
    [self layoutDayView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dayView updateCurrentTime];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[NSCalendar currentCalendar] isDateInToday:self.displayDate]) {
        [self.dayView scrollToCurrentTime:YES];
    }
}

- (ECDayView*)dayView {
    if (!_dayView) {
        ECDayView* dayView = [[ECDayView alloc] initWithFrame:CGRectZero displayDate:self.displayDate];
        _dayView = dayView;
        
        [self setupDayView:dayView];
        
        [self.view addSubview:_dayView];
    }
    
    return _dayView;
}

- (ECWeekdayPicker*)weekdayPicker
{
    if (!_weekdayPicker) {
        DDLogDebug(@"Creating weekday picker with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:self.displayDate]);
        ECWeekdayPicker* weekdayPicker = [[ECWeekdayPicker alloc] initWithDate:self.displayDate];
        
        _weekdayPicker = weekdayPicker;
        
        [self setupWeekdayPicker:weekdayPicker];
        
        [self.view addSubview:weekdayPicker];
    }
    
    return _weekdayPicker;
}

@synthesize displayDate = _displayDate;

- (NSDate*)displayDate
{
    if (!_displayDate) {
        _displayDate = [[NSDate date] beginningOfDay];
    }
    
    return _displayDate;
}

- (void)setDisplayDate:(NSDate *)displayDate
{
    DDLogDebug(@"Day View display date changed to %@", displayDate);
    _displayDate = displayDate;
    
    self.title = [self.dateFormatter stringFromDate:displayDate];
}

- (NSDateFormatter*)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMM dd, yyyy" options:0 locale:[NSLocale autoupdatingCurrentLocale]];
    }
    
    return _dateFormatter;
}

#pragma mark - View setup

#define WEEKDAY_PICKER_HEIGHT   74.0f
#define DAY_VIEW_CONTENT_HEIGHT 1200.0f

- (void)setupWeekdayPicker:(ECWeekdayPicker*)weekdayPicker
{
    weekdayPicker.pickerDelegate = self;
    weekdayPicker.pickerDataSource = self;
    DDLogDebug(@"Setting weekday picker selected date to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:self.displayDate]);
    [weekdayPicker setSelectedDate:self.displayDate];
}

- (void)setupDayView:(ECDayView*)dayView
{
    dayView.dayViewDataSource = self;
    dayView.dayViewDelegate = self;
    [dayView setDisplayDate:self.displayDate animated:NO];
}

- (void)layoutWeekdayPicker
{
    CGRect weekdayPickerFrame = CGRectMake(self.view.bounds.origin.x,
                                           CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                           self.view.bounds.size.width,
                                           WEEKDAY_PICKER_HEIGHT);
    
    self.weekdayPicker.frame = weekdayPickerFrame;
}

- (void)layoutDayView
{
    CGRect dayViewFrame = CGRectMake(self.view.bounds.origin.x,
                                     CGRectGetMaxY(self.weekdayPicker.frame),
                                     self.view.bounds.size.width,
                                     self.navigationController.toolbar.frame.origin.y - CGRectGetMaxY(self.weekdayPicker.frame) - 1); // -1 so toolbar separator will show
    
    self.dayView.frame = dayViewFrame;
}


#pragma mark - ECWeekdayPicker delegate and data source

- (void)weekdayPicker:(ECWeekdayPicker *)picker didSelectDate:(NSDate *)date
{
    if (![[NSCalendar currentCalendar] isDate:self.displayDate inSameDayAsDate:date]) {
        DDLogDebug(@"Weekday picker changed selected date to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
        self.displayDate = date;
        
        [self.dayView scrollToDate:date animated:YES];
    }
}

- (NSDate*)selectedDateForWeekdays:(NSArray *)weekdays
{
    NSDate* firstDayOfWeek = [weekdays firstObject];
    NSDate* lastDayOfWeek = [weekdays lastObject];
    if ([self.displayDate compare:[firstDayOfWeek beginningOfDay]] == NSOrderedDescending &&
        [self.displayDate compare:[lastDayOfWeek endOfDay]] == NSOrderedAscending) {
        return self.displayDate;
    }
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    for (NSDate* date in weekdays) {
        if ([calendar isDateInToday:date]) {
            return date;
        }
    }
    
    NSInteger weekdayIndex = [calendar components:NSCalendarUnitWeekday fromDate:self.displayDate].weekday;
    return weekdays[weekdayIndex - 1];
}

- (NSArray*)calendarsForDate:(NSDate *)date
{
    DDLogDebug(@"Weekday picker requeseted calendars for date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    NSMutableArray* mutableCalendars = [[NSMutableArray alloc] init];
    for (EKEvent* event in [[ECEventStoreProxy sharedInstance] eventsFrom:[date beginningOfDay] to:[date endOfDay]]) {
        if (![mutableCalendars containsObject:event.calendar]) {
            [mutableCalendars addObject:event.calendar];
        }
    }
    
    return [mutableCalendars copy];
}

#pragma mark - ECEditEventViewController Delegate

- (void)editEventViewControllerDidCancel:(ECEditEventViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editEventViewControllerDidSave:(ECEditEventViewController *)controller
{
    [self refreshEvents];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editEventViewControllerDidDelete:(ECEditEventViewController *)controller
{
    [self refreshEvents];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - ECDayView Data source and delegate

- (NSArray*)dayView:(ECDayView *)dayView eventsForDate:(NSDate *)date
{
    NSArray* events = [[ECEventStoreProxy sharedInstance] eventsFrom:[date beginningOfDay] to:[date endOfDay]];
    
    return events;
}

- (CGSize)contentSizeForDayView:(ECDayView *)dayView
{
    CGSize dayViewContentSize = CGSizeMake(self.view.bounds.size.width, DAY_VIEW_CONTENT_HEIGHT);
    
    return dayViewContentSize;
}

- (void)dayView:(ECDayView *)dayView didScrollFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    if (![[NSCalendar currentCalendar] isDate:toDate inSameDayAsDate:self.displayDate]){
        self.displayDate = toDate;
        
        DDLogDebug(@"Setting weekday picker selected date to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:toDate]);
        self.weekdayPicker.selectedDate = toDate;
    }
}

- (void)dayViewDidScrollTime:(ECDayView *)dayView
{
    self.userDidScrollDayViewSinceDateChange = YES;
}

- (void)dayView:(ECDayView *)dayView eventWasSelected:(EKEvent *)event
{
    [self presentEditEventViewControllerWithEvent:event];
}


#pragma mark - Editing Events

- (void)presentEditEventViewControllerWithEvent:(EKEvent*)event
{
    ECEditEventViewController* eevc = [self.storyboard instantiateViewControllerWithIdentifier:EC_EDIT_EVENT_VIEW_CONTROLLER_STORYBOARD_ID];
    eevc.event = event;
    eevc.startDate = [self.displayDate dateWithTimeOfDate:[[NSDate date] beginningOfHour]];
    eevc.delegate = self;
    
    [self.navigationController pushViewController:eevc animated:YES];
}


#pragma mark - User Events

- (void)refreshEvents
{
    [self.weekdayPicker refreshWeekdays];
    [self.dayView refreshCalendarEvents];
}

#pragma mark - UI Events

- (IBAction)addEventButtonTapped:(UIBarButtonItem *)sender
{
    [self presentEditEventViewControllerWithEvent:nil];
}

- (IBAction)todayButtonTapped:(UIBarButtonItem *)sender
{
    if ([[NSCalendar currentCalendar] isDateInToday:self.displayDate]) {
        [self.dayView scrollToCurrentTime:YES];
    } else {
        NSDate* todayDate = [[NSDate date] beginningOfDay];
        DDLogDebug(@"Setting weekday picker date to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:todayDate]);
        // weekday picker will call delegate method that syncs the dates
        [self.weekdayPicker setSelectedDate:todayDate];
    }
}
@end
