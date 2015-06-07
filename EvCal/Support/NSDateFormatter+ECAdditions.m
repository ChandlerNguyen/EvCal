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
        
        dateViewFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd" options:0 locale:[NSLocale currentLocale]];
    });
    
    return dateViewFormatter;
}

+ (instancetype)ecEventDatesFormatter
{
    static NSDateFormatter* eventDatesFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventDatesFormatter = [[NSDateFormatter alloc] init];
        eventDatesFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j:mm MMMM d, YYYY" options:0 locale:[NSLocale currentLocale]];
    });
    
    return eventDatesFormatter;
}

@end
