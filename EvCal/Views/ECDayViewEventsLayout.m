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

@property (nonatomic, strong) NSMutableDictionary* tempEventViewFrames;
@property (nonatomic, strong) NSDictionary* eventViewFrames;

@end

@implementation ECDayViewEventsLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumEventViewTimeInterval = 15 * 60; // 15 minutes
    }
    
    return self;
}

- (void)setMinimumEventViewTimeInterval:(NSTimeInterval)minimumEventViewTimeInterval
{
    _minimumEventViewTimeInterval = minimumEventViewTimeInterval;
    [self invalidateLayout];
}

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
    NSDate* defaultDate = [NSDate date];
    NSArray* eventViews = [self.layoutDataSource eventViewsForLayout:self];
    CGRect eventViewsBounds = [self.layoutDataSource layout:self boundsForEventViews:eventViews];
    NSDate* displayDate = [self requestDisplayDateForEventViews:eventViews defaultDate:defaultDate];
    
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
    CGFloat lastEndPoint = -1;
    
    NSArray* sortedEventViews = [eventViews sortedArrayUsingSelector:@selector(compare:)];
    
    // Columns is a jagged two dimensional array
    NSMutableArray* columns = [[NSMutableArray alloc] init];
    [self prepareVerticalFramesForEventViews:eventViews bounds:bounds displayDate:displayDate];
    
    for (ECEventView* eventView in sortedEventViews) {
        if (eventView.event.isAllDay) {
            [mutableEventViewFrames setObject:[NSValue valueWithCGRect:CGRectZero] forKey:eventView.event.eventIdentifier];
        } else {
            NSValue* eventViewFrameValue = [self.tempEventViewFrames objectForKey:eventView.event.eventIdentifier];
            CGRect tempEventViewFrame = [eventViewFrameValue CGRectValue];
            
            // this view doesn't overlap the previous cluster of views
            if (lastEndPoint != -1 && tempEventViewFrame.origin.y > lastEndPoint) {
                [mutableEventViewFrames addEntriesFromDictionary:[self framesForColumns:columns bounds:bounds displayDate:displayDate]];
                
                // start new cluster
                columns = [@[] mutableCopy];
                lastEndPoint = -1;
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
            if (lastEndPoint == -1 || CGRectGetMaxY(tempEventViewFrame) > lastEndPoint) {
                lastEndPoint = CGRectGetMaxY(tempEventViewFrame);
            }
            
            // layout current column setup
            if (columns.count > 0) {
                [mutableEventViewFrames addEntriesFromDictionary:[self framesForColumns:columns bounds:bounds displayDate:displayDate]];
            }
        }
    }
    
    self.tempEventViewFrames = nil;
    return [mutableEventViewFrames copy];
}

- (void)prepareVerticalFramesForEventViews:(NSArray*)eventViews bounds:(CGRect)bounds displayDate:(NSDate*)displayDate
{
    self.tempEventViewFrames = [[NSMutableDictionary alloc] init];
    for (ECEventView* eventView in eventViews) {
        CGRect tempEventViewFrame = CGRectMake(0,
                                               [self verticalPositionForDate:eventView.event.startDate relativeToDate:displayDate bounds:bounds],
                                               1,
                                               [self heightOfEventWithStartDate:eventView.event.startDate endDate:eventView.event.endDate displayDate:displayDate bounds:bounds]);
        [self.tempEventViewFrames setObject:[NSValue valueWithCGRect:tempEventViewFrame] forKey:eventView.event.eventIdentifier];
    }
}

- (NSDictionary*)framesForColumns:(NSArray*)columns bounds:(CGRect)bounds displayDate:(NSDate*)displayDate
{
    NSMutableDictionary* mutableColumnFrames = [[NSMutableDictionary alloc] init];
    NSInteger numGroups = columns.count;
    for (NSInteger i = 0; i < numGroups; i++) {
        NSArray* column = columns[i];
        for (NSInteger j = 0; j < column.count; j++) {
            ECEventView* eventView = column[j];
            NSValue* eventViewFrameValue = [self.tempEventViewFrames objectForKey:eventView.event.eventIdentifier];
            CGRect eventViewFrame;
            if (eventViewFrameValue) {
                eventViewFrame = [eventViewFrameValue CGRectValue];
                eventViewFrame.origin.x = bounds.origin.x + i * floorf(bounds.size.width / numGroups);
                eventViewFrame.size.width = floorf(bounds.size.width / numGroups);
            } else {
                eventViewFrame = CGRectMake(bounds.origin.x + i * floorf(bounds.size.width / numGroups),
                                            [self verticalPositionForDate:eventView.event.startDate relativeToDate:displayDate bounds:bounds],
                                            floorf(bounds.size.width / numGroups),
                                            [self heightOfEventWithStartDate:eventView.event.startDate endDate:eventView.event.endDate displayDate:displayDate bounds:bounds]);
            }
        
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


#pragma mark Height and Positioning

const static NSTimeInterval kOneHourTimeInterval =  60 * 60;

- (CGFloat)heightOfEventWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate displayDate:(NSDate *)displayDate bounds:(CGRect)bounds
{
    CGFloat height = 0;
    NSArray* hours = [displayDate hoursOfDay];
    CGFloat minimumHeightForBounds = floorf(bounds.size.height * ((self.minimumEventViewTimeInterval / kOneHourTimeInterval) / hours.count));
    
    if (bounds.size.height > 0) {
        float eventHoursInDay = [self hoursBetweenStartDate:startDate endDate:endDate relativeToDate:displayDate];
        
        height = MAX(floorf(bounds.size.height * (eventHoursInDay / hours.count)), minimumHeightForBounds);
    }
    
    return height;
}

- (float)hoursBetweenStartDate:(NSDate*)startDate endDate:(NSDate*)endDate relativeToDate:(NSDate*)date
{
    NSDate* beginningOfDay = [date beginningOfDay];
    NSDate* endOfDay = [date endOfDay];
    
    NSDate* start = nil;
    NSDate* end = nil;
    
    if ([startDate compare:beginningOfDay] == NSOrderedAscending) { // event starts before the given day
        start = beginningOfDay;
    } else {
        start = startDate;
    }
    
    if ([endDate compare:endOfDay] == NSOrderedDescending) { // event begins after the given day
        end = endOfDay;
    } else {
        end = endDate;
    }
    
    return (float)[end timeIntervalSinceDate:start] / kOneHourTimeInterval;
}

- (CGFloat)verticalPositionForDate:(NSDate *)date relativeToDate:(NSDate *)displayDate bounds:(CGRect)bounds
{
    if (!date || !displayDate) {
        return bounds.origin.y;
    }
    
    NSDate* beginningOfDay = [date beginningOfDay];
    if ([date compare:beginningOfDay] == NSOrderedAscending) {
        return bounds.origin.y;
    }
    
    NSDate* endOfDay = [date endOfDay];
    if ([date compare:endOfDay] == NSOrderedDescending) {
        return CGRectGetMaxY(bounds);
    }
    
    CGFloat position = bounds.origin.y;
    if (bounds.size.height > 0) {
        
        NSArray* hours = [date hoursOfDay];
        
        float hoursAfterBeginningOfDay = ([date timeIntervalSinceDate:beginningOfDay] / kOneHourTimeInterval);
        
        position += (bounds.size.height / hours.count) * hoursAfterBeginningOfDay;
    }
    
    return position;
}

- (NSDate*)closestDatePrecedingDate:(NSDate*)date inDates:(NSArray*)dates
{
    NSArray* sortedDates = [dates sortedArrayUsingSelector:@selector(compare:)];
    for (NSDate* otherDate in sortedDates) {
        NSComparisonResult result = [date compare:otherDate];
        
        switch (result) {
            case NSOrderedSame:
                return otherDate;
                break;
                
            case NSOrderedAscending:
                break;
                
            case NSOrderedDescending:
                return otherDate;
                break;
        }
    }
    
    DDLogError(@"Unable to determine which hour precedes the start date of an event while determining event view layout");
    return nil;
}

- (NSDate*)dateForVerticalPosition:(CGFloat)verticalPosition relativeToDate:(NSDate *)date bounds:(CGRect)bounds
{
    if (date) {
        NSDate* beginningOfDay = [date beginningOfDay];
        NSDate* endOfDay = [date endOfDay];
        
        CGFloat secondHeight = bounds.size.height / [endOfDay timeIntervalSinceDate:beginningOfDay];
        NSTimeInterval timeIntervalFromStartOfDay = (verticalPosition -bounds.origin.y) / secondHeight;
        
        return [beginningOfDay dateByAddingTimeInterval:timeIntervalFromStartOfDay];
    } else {
        DDLogError(@"Value for relative date should not be nil");
        return date;
    }
}

@end
