//
//  EKEvent+ECAdditions.m
//  EvCal
//
//  Created by Tom on 7/2/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "EKEvent+ECAdditions.h"

@implementation EKEvent (ECAdditions)

- (NSComparisonResult)compareStartAndEndDateWithEvent:(EKEvent*)otherEvent
{
    // this method should be moved to an EKEvent category
    NSComparisonResult startDateComparisonResult = [self compareStartDateWithEvent:otherEvent];
    if (startDateComparisonResult != NSOrderedSame) {
        return [self.endDate compare:otherEvent.endDate];
    } else {
        return startDateComparisonResult;
    }
}

@end
