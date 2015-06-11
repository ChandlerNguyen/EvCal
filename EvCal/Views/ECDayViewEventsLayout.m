//
//  ECDayViewEventsLayout.m
//  EvCal
//
//  Created by Tom on 6/11/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDayViewEventsLayout.h"

@interface ECDayViewEventsLayout()

@property (nonatomic, strong) NSMutableDictionary* eventViewFrames;

@end

@implementation ECDayViewEventsLayout

- (void)invalidateLayout
{
    self.eventViewFrames = nil;
}

- (CGRect)frameForEventView:(ECEventView *)eventView
{
    if (!self.eventViewFrames) {
        self.eventViewFrames = [self createEventViewFrames];
    }
    
    return CGRectZero;
}

- (NSMutableDictionary*)createEventViewFrames
{
    NSMutableDictionary* eventViewFrames = [[NSMutableDictionary alloc] init];
    
    NSArray* eventViews = [self.layoutDataSource eventViewsForLayout:self];
    CGRect eventViewsBounds = [self.layoutDataSource layout:self boundsForEventViews:eventViews];
    
    return eventViewFrames;
}

@end
