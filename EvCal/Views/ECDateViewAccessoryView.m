//
//  ECDateViewAccessoryView.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateViewAccessoryView.h"

@implementation ECDateViewAccessoryView

- (instancetype)initWithColor:(UIColor *)color eventCount:(NSInteger)eventCount
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.calendarColor = color;
        self.eventCount = eventCount;
    }
    
    return self;
}

@end
