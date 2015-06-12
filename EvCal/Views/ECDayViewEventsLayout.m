//
//  ECDayViewEventsLayout.m
//  EvCal
//
//  Created by Tom on 6/11/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//


// iOS Frameworks
@import EventKit;

// Helpers
#import "NSDate+CupertinoYankee.h"

#import "ECEventView.h"
#import "ECDayViewEventsLayout.h"


@interface ECDayViewEventsLayout()

@property (nonatomic, strong) NSDictionary* eventViewFrames;

@end

@implementation ECDayViewEventsLayout

- (void)invalidateLayout
{
    self.eventViewFrames = nil;
}

- (CGRect)frameForEventView:(ECEventView *)eventView
{
    if (!self.eventViewFrames ||
        ![self.eventViewFrames objectForKey:eventView.event.eventIdentifier]) {
        self.eventViewFrames = [self createEventViewFrames];
        
        if (![self.eventViewFrames objectForKey:eventView.event.eventIdentifier]) {
            DDLogError(@"Requesting frame for event view that is not provided by that data source");
            return CGRectZero;
        }
    }
    
    NSValue* frameValue = [self.eventViewFrames objectForKey:eventView.event.eventIdentifier];
    CGRect eventViewFrame = frameValue.CGRectValue;
    
    return eventViewFrame;
}

- (NSDictionary*)createEventViewFrames
{
    NSArray* eventViews = [self.layoutDataSource eventViewsForLayout:self];
    CGRect eventViewsBounds = [self.layoutDataSource layout:self boundsForEventViews:eventViews];
    NSDate* displayDate = [self requestDisplayDateForEventViews:eventViews defaultDate:[NSDate date]];
    
    return [self framesForEventViews:eventViews bounds:eventViewsBounds displayDate:displayDate];
}

- (NSDate*)requestDisplayDateForEventViews:(NSArray*)eventViews defaultDate:(NSDate*)defaultDate
{
    NSDate* displayDate = [self.layoutDataSource layout:self displayDateForEventViews:eventViews];
    
    if (!displayDate) {
        DDLogError(@"Display date provided by layout data source was nil, using default value of %@", defaultDate);
        return defaultDate;
    } else {
        return displayDate;
    }
}

- (NSDictionary*)framesForEventViews:(NSArray*)eventViews bounds:(CGRect)bounds displayDate:(NSDate*)displayDate
{
    NSMutableDictionary* mutableEventViewFrames = [[NSMutableDictionary alloc] init];
    
    // Prepare layout state
    NSDate* lastEndDate = nil;
    
    NSArray* sortedEventViews = [eventViews sortedArrayUsingSelector:@selector(compare:)];
    
    // Columns is a jagged two dimensional array
    NSMutableArray* columns = [[NSMutableArray alloc] init];
    
    for (ECEventView* eventView in sortedEventViews) {
        if (eventView.event.isAllDay) {
            [mutableEventViewFrames setObject:[NSValue valueWithCGRect:CGRectZero] forKey:eventView.event.eventIdentifier];
        } else {
            // this view doesn't overlap the previous cluster of views
            if (lastEndDate && [eventView.event.startDate compare:lastEndDate] == NSOrderedDescending) {
                [mutableEventViewFrames addEntriesFromDictionary:[self framesForColumns:columns bounds:bounds displayDate:displayDate]];
                
                // start new cluster
                columns = [@[] mutableCopy];
                lastEndDate = nil;
            }
            
            BOOL placed = NO;
            for (NSInteger i = 0; i < columns.count; i++) {
                // determine if view can be added to the end of a current column
                NSArray* column = columns[i];
                if (![self eventView:eventView overlapsEventView:[column lastObject]]) {
                    // add view to end of column
                    columns[i] = [column arrayByAddingObject:eventView];
                    placed = YES;
                    break;
                }
            }
            
            // view overlaps all columns, add a new column
            if (!placed) {
                [columns addObject:@[eventView]];
            }
            
            // last date isn't set or the view's end date is later than current end date
            if (!lastEndDate || [eventView.event.endDate compare:lastEndDate] == NSOrderedAscending) {
                lastEndDate = eventView.event.endDate;
            }
            
            // layout current column setup
            if (columns.count > 0) {
                [mutableEventViewFrames addEntriesFromDictionary:[self framesForColumns:columns bounds:bounds displayDate:displayDate]];
            }
        }
    }
    
    return [mutableEventViewFrames copy];
}

- (NSDictionary*)framesForColumns:(NSArray*)columns bounds:(CGRect)bounds displayDate:(NSDate*)displayDate
{
    NSMutableDictionary* mutableColumnFrames = [[NSMutableDictionary alloc] init];
    NSInteger numGroups = columns.count;
    for (NSInteger i = 0; i < numGroups; i++) {
        NSArray* column = columns[i];
        for (NSInteger j = 0; j < column.count; j++) {
            ECEventView* eventView = column[j];
            CGRect eventViewFrame = CGRectMake(bounds.origin.x + i * floorf(bounds.size.width / numGroups),
                                               [eventView verticalPositionInRect:bounds forDate:displayDate],
                                               floorf(bounds.size.width / numGroups),
                                               [eventView heightInRect:bounds forDate:displayDate]);
            [mutableColumnFrames setObject:[NSValue valueWithCGRect:eventViewFrame] forKey:eventView.event.eventIdentifier];
        }
    }
    
    return [mutableColumnFrames copy];
}

// PREDCONDITION
// This test assumes that the left event view precedes the right event view as
// defined by ECEventView's compare method
- (BOOL)eventView:(ECEventView*)left overlapsEventView:(ECEventView*)right
{
    BOOL leftStartsAboveRight = [left.event.startDate compare:right.event.endDate] == NSOrderedAscending;
    BOOL rightStartsAboveLeft = [left.event.endDate compare:right.event.startDate] == NSOrderedAscending;
    
    return leftStartsAboveRight || rightStartsAboveLeft;
}


@end
