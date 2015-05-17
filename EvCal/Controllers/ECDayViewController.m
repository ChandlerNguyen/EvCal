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
#import "ECEventLoader.h"

@interface ECDayViewController ()

@property (nonatomic, weak) UIView* dayView;

@end

@implementation ECDayViewController

#pragma mark - Lifecycle and Properties

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dayView.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEvents) name:ECEventLoaderAuthorizationStatusChangedNotification object:nil];
    [self refreshEvents];
}

- (UIView*)dayView {
    if (!_dayView) {
        UIView* dayView = [[ECDayView alloc] initWithFrame:self.view.bounds];
        _dayView = dayView;
        [self.view addSubview:_dayView];
    }
    
    return _dayView;
}

@synthesize displayDate = _displayDate;

- (NSDate*)displayDate
{
    if (!_displayDate) {
        _displayDate = [NSDate date];
    }
    
    return _displayDate;
}

- (void)setDisplayDate:(NSDate *)displayDate
{
    _displayDate = displayDate;
    [self refreshEvents];
}

#pragma mark - User Events

- (void)refreshEvents
{
    NSArray* events = [[ECEventLoader sharedInstance] loadEventsFrom:[self.displayDate beginningOfDay] to:[self.displayDate endOfDay]];

    for (EKEvent* event in events) {
        DDLogInfo(@"Loaded Event: %@", event.title);
    }
}


@end
