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
#import "CocoaLumberjack.h"

// EvCal Classes
#import "ECDayViewController.h"
#import "ECDayView.h"
#import "ECEventStoreProxy.h"
#import "ECEventViewFactory.h"
#import "ECWeekdayPicker.h"

@interface ECDayViewController () <ECWeekdayPickerDelegate>

@property (nonatomic, weak) ECWeekdayPicker* weekdayPicker;
@property (nonatomic, weak) ECDayView* dayView;
@property (nonatomic, weak) UIView* statusBarCover;

@end

@implementation ECDayViewController

#pragma mark - Lifecycle and Properties

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupStatusBarCover];
    [self setupWeekdayPicker];
    [self setupDayView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEvents) name:ECEventStoreProxyAuthorizationStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEvents) name:ECEventStoreProxyCalendarChangedNotification object:nil];
    [self refreshEvents];
}

- (ECDayView*)dayView {
    if (!_dayView) {
        ECDayView* dayView = [[ECDayView alloc] initWithFrame:CGRectZero];
        _dayView = dayView;
        dayView.displayDate = self.displayDate;
        [self.view addSubview:_dayView];
    }
    
    return _dayView;
}

- (UIView*)statusBarCover
{
    if (!_statusBarCover) {
        UIView* statusBarCover = [[UIView alloc] initWithFrame:CGRectZero];
        
        _statusBarCover = statusBarCover;
        [self.view addSubview:statusBarCover];
    }
    
    return _statusBarCover;
}

- (ECWeekdayPicker*)weekdayPicker
{
    if (!_weekdayPicker) {
        ECWeekdayPicker* weekdayPicker = [[ECWeekdayPicker alloc] initWithDate:self.displayDate];
        
        _weekdayPicker = weekdayPicker;
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
    DDLogDebug(@"Day View display date changed OLD: %@, NEW: %@", _displayDate, displayDate);
    _displayDate = displayDate;
    
    [self refreshEvents];
}

#pragma mark - View setup

#define WEEKDAY_PICKER_HEIGHT   88.0f

- (void)setupStatusBarCover
{
    self.statusBarCover.backgroundColor = [UIColor whiteColor];
    
    CGRect statusBarCoverFrame = CGRectMake(self.view.bounds.origin.x,
                                            self.view.bounds.origin.y,
                                            self.view.bounds.size.width,
                                            [UIApplication sharedApplication].statusBarFrame.size.height);
    self.statusBarCover.frame = statusBarCoverFrame;
}

- (void)setupWeekdayPicker
{
    self.weekdayPicker.pickerDelegate = self;
    
    CGRect weekdayPickerFrame = CGRectMake(self.view.bounds.origin.x,
                                           CGRectGetMaxY(self.statusBarCover.frame),
                                           self.view.bounds.size.width,
                                           WEEKDAY_PICKER_HEIGHT);
    
    self.weekdayPicker.frame = weekdayPickerFrame;
}

- (void)setupDayView
{
    self.dayView.backgroundColor = [UIColor whiteColor];
    
    CGRect dayViewFrame = CGRectMake(self.view.bounds.origin.x,
                                     CGRectGetMaxY(self.weekdayPicker.frame),
                                     self.view.bounds.size.width,
                                     self.view.bounds.size.height - (self.statusBarCover.frame.size.height + self.weekdayPicker.frame.size.height));
    
    CGSize dayViewContentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 2);
    self.dayView.frame = dayViewFrame;
    self.dayView.contentSize = dayViewContentSize;
}

#pragma mark - Selecting Dates

- (void)weekdayPicker:(ECWeekdayPicker *)picker didSelectDate:(NSDate *)date
{
    self.displayDate = date;
    self.dayView.displayDate = date;
    
    [self refreshEvents];
}

#pragma mark - User Events

- (void)refreshEvents
{
    NSArray* events = [[ECEventStoreProxy sharedInstance] eventsFrom:[self.displayDate beginningOfDay] to:[self.displayDate endOfDay]];

    for (EKEvent* event in events) {
        DDLogInfo(@"Loaded Event: %@", event.title);
    }
    
    NSArray* eventViews = [ECEventViewFactory eventViewsForEvents:events];
    
    [self.dayView clearEventViews];
    [self.dayView addEventViews:eventViews];
}


@end
