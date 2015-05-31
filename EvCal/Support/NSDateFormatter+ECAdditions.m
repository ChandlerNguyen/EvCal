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
    static NSDateFormatter* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
        
        instance.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd" options:0 locale:[NSLocale currentLocale]];
    });
    
    return instance;
}

@end
