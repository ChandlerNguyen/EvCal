//
//  ECRecurrenceRuleFormatter.m
//  EvCal
//
//  Created by Tom on 7/6/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECRecurrenceRuleFormatter.h"

@implementation ECRecurrenceRuleFormatter

- (EKRecurrenceRule*)recurrenceRuleForRecurrenceType:(ECRecurrenceRuleType)type
{
    switch (type) {
        case ECRecurrenceRuleTypeDaily:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:nil];
            
        case ECRecurrenceRuleTypeWeekly:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 end:nil];
            
        case ECRecurrenceRuleTypeMonthly:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:1 end:nil];
            
        case ECRecurrenceRuleTypeYearly:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 end:nil];
            
        case ECRecurrenceRuleTypeWeekdays:
            return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                                                interval:1
                                                           daysOfTheWeek:@[[EKRecurrenceDayOfWeek dayOfWeek:EKMonday],
                                                                           [EKRecurrenceDayOfWeek dayOfWeek:EKTuesday],
                                                                           [EKRecurrenceDayOfWeek dayOfWeek:EKWednesday],
                                                                           [EKRecurrenceDayOfWeek dayOfWeek:EKThursday],
                                                                           [EKRecurrenceDayOfWeek dayOfWeek:EKFriday]]
                                                          daysOfTheMonth:nil
                                                         monthsOfTheYear:nil
                                                          weeksOfTheYear:nil
                                                           daysOfTheYear:nil
                                                            setPositions:nil
                                                                     end:nil];
            
        // The customRecurrenceRuleWithFrequency:interval: method should be returned
        case ECRecurrenceRuleTypeCustom:
        default:
            DDLogWarn(@"Attempting to create custom recurrence rule wihtout sepcifying parameters");
            return nil;
    }
}

@end
