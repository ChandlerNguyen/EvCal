//
//  ECDateViewFactory.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateViewFactory.h"
#import "ECDateView.h"
#import "ECDateViewAccessoryView.h"
#import "ECEventStoreProxy.h"

#import "NSDate+CupertinoYankee.h"

@interface ECDateViewFactory()

@end

@implementation ECDateViewFactory

- (ECDateView*)dateViewForDate:(NSDate *)date
{
    ECDateView* dateView = [[ECDateView alloc] initWithDate:date];
    
    [self addAccessoryViewsForDate:date toDateView:dateView];
    
    return dateView;
}

- (void)configureDateView:(ECDateView *)dateView forDate:(NSDate *)date
{
    dateView.date = date;
    
    [self addAccessoryViewsForDate:date toDateView:dateView];    
}

- (void)addAccessoryViewsForDate:(NSDate*)date toDateView:(ECDateView*)dateView
{
    ECEventStoreProxy* eventStoreProxy = [ECEventStoreProxy sharedInstance];
    
    NSMutableArray* mutableAccessoryViews = [[NSMutableArray alloc] init];
    for (EKCalendar* calendar in eventStoreProxy.calendars) {
        NSArray* events = [eventStoreProxy eventsFrom:[date beginningOfDay] to:[date endOfDay] in:@[calendar]];
        if (events.count > 0) {
            ECDateViewAccessoryView* accessoryView = [[ECDateViewAccessoryView alloc] initWithColor:[UIColor colorWithCGColor:calendar.CGColor]];
            [mutableAccessoryViews addObject:accessoryView];
        }
    }
    
    dateView.eventAccessoryViews = [mutableAccessoryViews copy];
}
@end