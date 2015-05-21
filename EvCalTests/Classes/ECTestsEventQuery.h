//
//  ECTestsEventQuery.h
//  EvCal
//
//  Created by Tom on 5/21/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Describes the date range of the query. 
 *  Default is ECTestsEventQueryTypeDay
 */
typedef NS_ENUM(NSInteger, ECTestsEventQueryType){
    /**
     *  The query's start date will be set to the first second of the same day
     *  of the start date initially specified. The end date will be the last
     *  second of the same day.
     */
    ECTestsEventQueryTypeDay,
    /**
     *  The query's start date will be set to the first second of the weekday
     *  of the week containing the start date initially specified. The end date 
     *  will be the last second of the last day of the same week.
     */
    ECTestsEventQueryTypeWeek,
    /**
     *  The query's start date will be set to the first second of the first day
     *  of the month containing the start date initially specified. The end date
     *  will be the last second of the last day of the same month.
     */
    ECTestsEventQueryTypeMonth,
    /**
     *  The query's start date will be set to the first second of the first day
     *  of the year containing the start date initially specfied. The end date
     *  will be the last second of the last day of the same year.
     */
    ECTestsEventQueryTypeYear,
};

@interface ECTestsEventQuery : NSObject

@property (nonatomic, strong) NSDate* startDate; // default is random date
@property (nonatomic, strong) NSDate* endDate; // default is nil (subclasses override)
@property (nonatomic, strong) NSArray* calendars; // default is nil

/**
 *  DEFAULT CONSTRUCTOR
 *  Creates a new event query with the given start date.
 *
 *  @param startDate The start date for the query or nil for a random start date
 *  @param days The number of days
 *  @param calendars An array of EKCalendars to be
 *
 *  @return A newly created event query with start date and calendars set
 */
- (instancetype)initWithStartDate:(NSDate*)startDate type:(ECTestsEventQueryType)type calendars:(NSArray*)calendars;

@end
