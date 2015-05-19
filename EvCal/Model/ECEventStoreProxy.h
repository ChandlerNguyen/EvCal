//
//  ECEventStoreProxy.h
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ECEventStoreProxyAuthorizationStatusChangedNotification @"AuthorizationStatusChanged"
#define ECEventStoreProxyCalendarChangedNotification            @"CalendarChanged"

typedef NS_ENUM(NSUInteger, ECAuthorizationStatus) {
    ECAuthorizationStatusNotDetermined,
    ECAuthorizationStatusDenied,
    ECAuthorizationStatusAuthorized,
};

@interface ECEventStoreProxy : NSObject


@property (nonatomic, readonly) ECAuthorizationStatus authorizationStatus;

//------------------------------------------------------------------------------
// @name Calendars
//------------------------------------------------------------------------------

// The user's event calendars
@property (nonatomic, readonly) NSArray* calendars;
// Default calendar is determined by phone settings
@property (nonatomic, readonly) EKCalendar* defaultCalendarForNewEvents;

/**
 *  Returns the calendar object with the given identfier. Calendar identifiers
 *  can become stale after synchronization. Do not rely on the identifier to
 *  reliably fetch the desired calendar.
 *
 *  @param identifier The identifier of the calendar to be retrieved
 *
 *  @return The calendar with the given identifier or nil if no such calendar 
 *          could be found.
 */
- (EKCalendar*)calendarWithIdentifier:(NSString*)identifier;


//------------------------------------------------------------------------------
// @name Accessing shared instance
//------------------------------------------------------------------------------

/**
 *  Returns the shared instance of ECEventStoreProxy
 */
+ (instancetype)sharedInstance;

//------------------------------------------------------------------------------
// @name Accessing User Events
//------------------------------------------------------------------------------

/**
 *  Creates and returns an array of all of the user's events which fall within 
 *  a given date range.
 *
 *  @param startDate The start date of the range of user events to load.
 *  @param endDate   The end date of the range of user events to load.
 *
 *  @return An array of EKEvents or nil if no events could be fetched or if the user
 *          has denied calendar access.
 */
- (NSArray*)eventsFrom:(NSDate*)startDate to:(NSDate*)endDate;

/**
 *  Creates and returns an array of the user's events in the given calendar which
 *  fall within the given date range.
 *
 *  @param startDate The start date of the range of user events to load.
 *  @param endDate   The end date of the range of user events to load.
 *  @param calendars The calendars from which to load events. Passing nil
 *                   indicates that events from all calendars should be loaded.
 *
 *  @return An array of EKEvents or nil if no events could be fetched or if the user
 *          has denied calendar access.
 */
- (NSArray*)eventsFrom:(NSDate*)startDate to:(NSDate*)endDate in:(NSArray*)calendars;

@end
