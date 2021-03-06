//
//  NSDateFormatter+ECAdditions.m
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "NSDateFormatter+ECAdditions.h"

@implementation NSDateFormatter (ECAdditions)

+ (instancetype)ecDateViewFormatter
{
    static NSDateFormatter* dateViewFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateViewFormatter = [[NSDateFormatter alloc] init];
        
        dateViewFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"d" options:0 locale:[NSLocale currentLocale]];
    });
    
    return dateViewFormatter;
}

+ (instancetype)ecEventDatesFormatter
{
    static NSDateFormatter* eventDatesFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventDatesFormatter = [[NSDateFormatter alloc] init];
        eventDatesFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j:mm MMMM d, yyyy" options:0 locale:[NSLocale currentLocale]];
    });
    
    return eventDatesFormatter;
}

+ (instancetype)ecMonthFormatter
{
    static NSDateFormatter* monthFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monthFormatter = [[NSDateFormatter alloc] init];
        monthFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMM yyyy" options:0 locale:[NSLocale currentLocale]];
    });
    
    return monthFormatter;
}

@end
