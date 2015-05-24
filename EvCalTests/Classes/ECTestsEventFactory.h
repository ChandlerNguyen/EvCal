//
//  ECTestsEventFactory.h
//  EvCal
//
//  Created by Tom on 5/23/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import <Foundation/Foundation.h>

@interface ECTestsEventFactory : NSObject

+ (EKEvent*)randomEventInStore:(EKEventStore*)store calendar:(EKCalendar*)calendar;
+ (EKEvent*)randomEventInDay:(NSDate*)date store:(EKEventStore*)store calendar:(EKCalendar*)calendar allowMultipleDays:(BOOL)multipleDays;

@end
