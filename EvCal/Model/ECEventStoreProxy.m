//
//  ECEventStoreProxy.m
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//



@import EventKit;
#import "ECEventStoreProxy.h"


@interface ECEventStoreProxy()

@property (nonatomic, readwrite) ECAuthorizationStatus authorizationStatus;

@property (nonatomic, strong) EKEventStore* eventStore;

@end

@implementation ECEventStoreProxy

#pragma mark - Lifecycle and Properties

+ (instancetype)sharedInstance
{
    __strong static ECEventStoreProxy* _loader = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _loader = [[ECEventStoreProxy alloc] init];
        DDLogDebug(@"Shared ECEventStoreProxy created");
    });
    
    return _loader;
}

// Clients of the ECEventStoreProxy should only access the shared instance.
// This init method exists only for testing purposes (to ensure clean state).
// No behavior guarantees are made if multiple proxies are instantiated.
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCalendarChangedNotification) name:EKEventStoreChangedNotification object:nil];
        DDLogDebug(@"Event store proxy is added to event store change observers");
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (EKEventStore*)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
        DDLogDebug(@"EKEvent store created");
    }
    
    return _eventStore;
}

- (ECAuthorizationStatus)authorizationStatus
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
            DDLogDebug(@"Current Authorization Status: Not Determined");
            return ECAuthorizationStatusNotDetermined;
            
        // treat restricted and denied as the same
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            DDLogDebug(@"Current Authorization Status: Denied");
            return ECAuthorizationStatusDenied;
            
        case EKAuthorizationStatusAuthorized:
            DDLogDebug(@"Current Authorization Status: Authorized");
            return ECAuthorizationStatusAuthorized;
    } ;
}

#pragma mark - Posting notifications


- (void)postAuthorizationStatusChangedNotification
{
    DDLogDebug(@"Posting authorization status changed notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:ECEventStoreProxyAuthorizationStatusChangedNotification object:nil];
}

- (void)postCalendarChangedNotification
{
    DDLogDebug(@"Posting calendar changed notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:ECEventStoreProxyCalendarChangedNotification object:nil];
}



#pragma mark - Loading User Events

- (NSString*)stringForCalendars:(NSArray*)calendars
{
    NSMutableString* calendarString = [[NSMutableString alloc] init];
    if (!calendars) {
        [calendarString appendString:@"all calendars"];
    } else {
        NSString* separator = @"";
        for (EKCalendar* calendar in calendars) {
            [calendarString appendFormat:@"%@%@", separator, calendar.title];
            separator = @", ";
        }
    }
    
    return [calendarString copy];
}

- (BOOL)validateStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    if (!startDate) {
        DDLogError(@"Start date is nil");
        return NO;
    }
    
    if (!endDate) {
        DDLogError(@"End date is nil");
        return NO;
    }
    
    if ([startDate compare:endDate] != NSOrderedAscending) {
        DDLogError(@"Start date must be prior to end date");
        return NO;
    }
    
    return YES;
}

- (NSArray*)eventsFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    return [self eventsFrom:startDate to:endDate in:nil];
}

- (NSArray*)eventsFrom:(NSDate *)startDate to:(NSDate *)endDate in:(NSArray *)calendars
{
    NSString* calendarString = [self stringForCalendars:calendars];
    DDLogDebug(@"Fetching events from %@ to %@ in %@", startDate, endDate, calendarString);

    if (![self validateStartDate:startDate endDate:endDate]) {
        return nil;
    }
    
    switch (self.authorizationStatus) {
        case ECAuthorizationStatusNotDetermined:
            [self requestAccessToEvents];
            DDLogInfo(@"Must request access to events prior to loading them");
            return nil;
            
        case ECAuthorizationStatusDenied:
            DDLogInfo(@"Current authorization status does not allow reading of user events");
            return nil;
        
        case ECAuthorizationStatusAuthorized: {
            NSPredicate* dateRangePredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendars];
            NSArray* events = [self.eventStore eventsMatchingPredicate:dateRangePredicate];
            DDLogDebug(@"Loaded %lu events", (unsigned long)events.count);
            return events;
        }
    }
}

#pragma mark - Managing Calendar Access

- (void)requestAccessToEvents
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError* err) {
        if (!err) {
            DDLogInfo(@"Calendar authorization status changed");
            [self postAuthorizationStatusChangedNotification];
        } else {
            DDLogError(@"Error requesting calendar authorization: %@, %@", err, err.description);
        }
    }];
}


@end
