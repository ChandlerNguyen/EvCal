//
//  NSCalendar+ECTestSwizzle.m
//  EvCal
//
//  Created by Tom on 5/27/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "NSCalendar+ECTestSwizzle.h"
#import <objc/runtime.h> // Voodoo ahead!

@implementation NSCalendar (ECTestSwizzle)

+ (void)swizzleDaylightSavingTimeZone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = object_getClass((id)self);
        
        SEL currentCalendarSelector = @selector(currentCalendar);
        SEL currentCalendarNYTimeZoneSelector = @selector(currentCalendarNYTimeZone);
        
        Method currentCalendarMethod = class_getClassMethod(class, currentCalendarSelector);
        Method currentCalendarNYTimeZoneMethod = class_getClassMethod(class, currentCalendarNYTimeZoneSelector);
        
        BOOL didAddMethod = class_addMethod(class,
                                            currentCalendarSelector,
                                            method_getImplementation(currentCalendarNYTimeZoneMethod),
                                            method_getTypeEncoding(currentCalendarNYTimeZoneMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                currentCalendarNYTimeZoneSelector,
                                method_getImplementation(currentCalendarMethod),
                                method_getTypeEncoding(currentCalendarMethod));
        } else {
            method_exchangeImplementations(currentCalendarMethod, currentCalendarNYTimeZoneMethod);
        }
    });
}

+ (NSCalendar*)currentCalendarNYTimeZone
{
    NSCalendar* calendar = [NSCalendar currentCalendarNYTimeZone];
    
    NSTimeZone* nyTimeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    calendar.timeZone = nyTimeZone;
    
    return calendar;
}

@end
