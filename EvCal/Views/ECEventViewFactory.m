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

@end
