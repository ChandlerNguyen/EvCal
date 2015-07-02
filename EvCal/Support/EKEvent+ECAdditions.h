//
//  EKEvent+ECAdditions.h
//  EvCal
//
//  Created by Tom on 7/2/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKEvent (ECAdditions)

/**
 *  Compares the receiver with another event according to their start dates
 *  and then end dates.
 *
 *  @param otherEvent The event against which to compare the receiver.
 *
 *  @return The result of comparing the events start dates or the end dates if
 *          the start dates are identical.
 */
- (NSComparisonResult)compareStartAndEndDateWithEvent:(EKEvent*)otherEvent;

@end
