//
//  ECDateViewAccessoryView.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateViewAccessoryView.h"

@implementation ECDateViewAccessoryView

- (instancetype)initWithColor:(UIColor *)color
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.calendarColor = color;
        self.backgroundColor = color;
        self.layer.cornerRadius = 4.0f;
    }
    
    return self;
}

@end
