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
        [[NSNotificationCenter defaultCenter] addObserver:_loader selector:@selector(postCalendarChangedNotification) name:EKEventStoreChangedNotification object:nil];
        DDLogDebug(@"Shared ECEventStoreProxy created");
    });
    
    return _loader;
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

- (NSArray*)loadEventsFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    return [self loadEventsFrom:startDate to:endDate in:nil];
}

- (NSArray*)loadEventsFrom:(NSDate *)startDate to:(NSDate *)endDate in:(NSArray *)calendars
{
    DDLogDebug(@"Loading events from %@ to %@ in [%@]", startDate, endDate, calendars ? @"all calendars" : calendars);
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
