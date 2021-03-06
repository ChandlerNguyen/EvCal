//
//  ECDateViewFactory.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDateViewFactory.h"
#import "ECDateView.h"
#import "ECEventStoreProxy.h"

#import "NSDate+CupertinoYankee.h"

@interface ECDateViewFactory()

@end

@implementation ECDateViewFactory

- (ECDateView*)dateViewForDate:(NSDate *)date
{
    if (date) {
        return [[ECDateView alloc] initWithDate:date];
    } else {
        return nil;
    }
}

- (NSArray*)dateViewsForDates:(NSArray *)dates reusingViews:(NSArray *)reusableViews
{
    if (dates) {
        NSMutableArray* mutableDates = [dates mutableCopy];
        NSMutableArray* mutableReusableViews = [reusableViews mutableCopy];
        NSMutableArray* mutableDateViews = [[NSMutableArray alloc] init];
        
        while (mutableDates.count > 0) {
            NSDate* date = [mutableDates firstObject];
            [mutableDates removeObject:date];
            
            ECDateView* dateView = [mutableReusableViews firstObject];
            if (!dateView) {
                dateView = [[ECDateView alloc] initWithDate:date];
            } else {
                dateView.date = date;
                
                [mutableReusableViews removeObject:dateView];
            }
            
            [mutableDateViews addObject:dateView];
        }
        
        return [mutableDateViews copy];
    } else {
        return nil;
    }
}

@end
