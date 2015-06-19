//
//  ECEventViewFactory.m
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Moduels
@import EventKit;

// EvCal Classes
#import "ECEventViewFactory.h"
#import "ECEventView.h"

@implementation ECEventViewFactory

+ (ECEventView*)eventViewForEvent:(EKEvent *)event
{
    return [[ECEventView alloc] initWithEvent:event];
}

+ (NSArray*)eventViewsForEvents:(NSArray *)events
{
    NSMutableArray* eventViews = [[NSMutableArray alloc] init];
    for (EKEvent* event in events) {
        [eventViews addObject:[[ECEventView alloc] initWithEvent:event]];
    }
    
    return [eventViews copy];
}

+ (NSArray*)eventViewsForEvents:(NSArray *)events reusingViews:(NSArray *)reusableViews
{
    NSMutableArray* mutableEvents = [events mutableCopy];
    NSMutableArray* mutableReusableViews = [reusableViews mutableCopy];
    NSMutableArray* mutableEventViews = [[NSMutableArray alloc] init];
    
    while (mutableEvents.count > 0) {
        EKEvent* event = [mutableEvents firstObject];
        ECEventView* eventView = [mutableReusableViews firstObject];
        
        if (eventView) {
            eventView.event = event;
            [mutableReusableViews removeObject:eventView];
        } else {
            eventView = [self eventViewForEvent:event];
        }
        
        [mutableEvents removeObject:event];
        [mutableEventViews addObject:eventView];
    }
    
    return [mutableEventViews copy];
}

@end
