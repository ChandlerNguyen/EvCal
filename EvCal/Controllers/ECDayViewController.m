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
#import "ECEventViewFactory.h"
#import "ECWeekdayPicker.h"

@interface ECDayViewController () <ECWeekdayPickerDelegate, ECEditEventViewControllerDelegate, UIScrollViewDelegate>

// Buttons
@property (nonatomic, weak) IBOutlet UIBarButtonItem* addEventButton;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;

// Day views
@property (nonatomic) BOOL userScrolledDayViewAfterSelectingDate;
@property (nonatomic, weak) ECDayView* dayView;
@property (nonatomic, weak) ECDayView* nextDayView;

// Date picker
@property (nonatomic, weak) ECWeekdayPicker* weekdayPicker;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;

@end

@implementation ECDayViewController

#pragma mark - Lifecycle and Properties

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupWeekdayPicker];
    [self setupDayView];
    
    self.title = [self.dateFormatter stringFromDate:self.displayDate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEvents) name:ECEventStoreProxyAuthorizationStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEvents) name:ECEventStoreProxyCalendarChangedNotification object:nil];
    [self refreshEvents];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self layoutWeekdayPicker];
    [self layoutDayView];
    //[self layoutNextDayView];
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

- (ECDayView*)nextDayView
{
    if (!_nextDayView) {
        ECDayView* nextDayView = [[ECDayView alloc] initWithFrame:CGRectZero];
        _nextDayView = nextDayView;
        nextDayView.displayDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:self.displayDate options:0];
        [self.view addSubview:_nextDayView];
    }
    
    return _nextDayView;
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
    
    self.title = [self.dateFormatter stringFromDate:displayDate];
    
    [self refreshEvents];
}

- (NSDateFormatter*)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMM yyyy" options:0 locale:[NSLocale autoupdatingCurrentLocale]];
    }
    
    return _dateFormatter;
}

#pragma mark - View setup

#define WEEKDAY_PICKER_HEIGHT   74.0f


- (void)setupWeekdayPicker
{
    self.weekdayPicker.pickerDelegate = self;
    [self.weekdayPicker setSelectedDate:self.displayDate animated:NO];
}

- (void)setupDayView
{
    self.dayView.delegate = self;
    self.dayView.displayDate = self.displayDate;
}

- (void)layoutWeekdayPicker
{
    CGRect weekdayPickerFrame = CGRectMake(self.view.bounds.origin.x,
                                           CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                           self.view.bounds.size.width,
                                           WEEKDAY_PICKER_HEIGHT);
    
    DDLogDebug(@"Weekday Picker Frame: %@", NSStringFromCGRect(weekdayPickerFrame));
    
    self.weekdayPicker.frame = weekdayPickerFrame;
}

- (void)layoutDayView
{
    CGRect dayViewFrame = CGRectMake(self.view.bounds.origin.x,
                                     CGRectGetMaxY(self.weekdayPicker.frame),
                                     self.view.bounds.size.width,
                                     self.bottomToolbar.frame.origin.y - CGRectGetMaxY(self.weekdayPicker.frame) - 1); // -1 so toolbar separator will show
    
    CGSize dayViewContentSize = CGSizeMake(self.view.bounds.size.width, 1200.0f);
    
    DDLogDebug(@"Day View Frame: %@", NSStringFromCGRect(dayViewFrame));
    DDLogDebug(@"Day View Content Size: %@", NSStringFromCGSize(dayViewContentSize));
    
    self.dayView.frame = dayViewFrame;
    self.dayView.contentSize = dayViewContentSize;
}

//- (void)layoutNextDayView
//{
//    CGRect nextDayViewFrame = CGRectMake(self.view.bounds.origin.x + self.view.bounds.size.width, // moved one screen to the right
//                                         CGRectGetMaxY(self.weekdayPicker.frame),
//                                         self.view.bounds.size.width,
//                                         self.bottomToolbar.frame.origin.y - CGRectGetMaxY(self.weekdayPicker.frame) - 1); // -1 so toolbar separator will show
//    
//    CGSize
//}

#pragma mark - ECWeekdayPicker Delegate

- (void)weekdayPicker:(ECWeekdayPicker *)picker didSelectDate:(NSDate *)date
{
    self.displayDate = date;
    self.dayView.displayDate = date;
    self.userScrolledDayViewAfterSelectingDate = NO;
    
    [self refreshEvents];
    [self performSelector:@selector(autoScrollDayView:) withObject:date afterDelay:0.5f];
}

- (void)weekdayPicker:(ECWeekdayPicker *)picker didScrollFrom:(NSArray *)fromWeek to:(NSArray *)toWeek
{
    // pass
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


#pragma mark - Editing Events

- (void)eventViewWasTapped:(ECEventView*)eventView
{
    DDLogInfo(@"Event view tapped, Event Title: %@", eventView.event.title);
    
    [self presentEditEventViewControllerWithEvent:eventView.event];
}

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
    NSArray* events = [[ECEventStoreProxy sharedInstance] eventsFrom:[self.displayDate beginningOfDay] to:[self.displayDate endOfDay]];

    for (EKEvent* event in events) {
        DDLogInfo(@"Loaded Event: %@", event.title);
    }
    
    NSArray* eventViews = [ECEventViewFactory eventViewsForEvents:events];
    [self addTapListenerToEventViews:eventViews];
    
    [self.dayView clearEventViews];
    [self.dayView addEventViews:eventViews];
}

- (void)addTapListenerToEventViews:(NSArray*)eventViews
{
    for (ECEventView* eventView in eventViews) {
        [eventView addTarget:self action:@selector(eventViewWasTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - UI Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (IBAction)addEventButtonTapped:(UIBarButtonItem *)sender
{
    [self presentEditEventViewControllerWithEvent:nil];
}

- (IBAction)todayButtonTapped:(UIBarButtonItem *)sender
{
    self.userScrolledDayViewAfterSelectingDate = NO;
    [self.weekdayPicker setSelectedDate:[[NSDate date] beginningOfDay] animated:YES];
}

- (void)autoScrollDayView:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    if ([calendar isDate:date inSameDayAsDate:self.displayDate]) {
        if ([calendar isDate:date inSameDayAsDate:[NSDate date]] && !self.userScrolledDayViewAfterSelectingDate) {
            [self.dayView scrollToCurrentTime:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[ECDayView class]]) {
        self.userScrolledDayViewAfterSelectingDate = YES;
    }
}

@end
