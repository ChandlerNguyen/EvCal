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
            
        default:
            return nil;
    }
}

@end
