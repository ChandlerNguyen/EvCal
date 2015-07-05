//
//  ECEventStoreProxy.m
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEventStoreProxy.h"
#import "ECEventCache.h"

@interface ECEventStoreProxy() <ECEventCacheDataSource>

@property (nonatomic, readwrite) ECAuthorizationStatus authorizationStatus;

@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) ECEventCache* eventCache;

@end

@implementation ECEventStoreProxy

#pragma mark - Lifecycle and Properties

+ (instancetype)sharedInstance
{
    __strong static ECEventStoreProxy* _loader = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _loader = [[ECEventStoreProxy alloc] init];
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
    }
    
    return _eventStore;
}

- (ECAuthorizationStatus)authorizationStatus
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
            return ECAuthorizationStatusNotDetermined;
            
        // treat restricted and denied as the same
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            return ECAuthorizationStatusDenied;
            
        case EKAuthorizationStatusAuthorized:
            return ECAuthorizationStatusAuthorized;
    } ;
}

- (ECEventCache*)eventCache
{
    if (!_eventCache) {
        _eventCache = [[ECEventCache alloc] init];
        _eventCache.cacheDataSource = self;
    }
    
    return _eventCache;
}

#pragma mark - Posting notifications


- (void)postAuthorizationStatusChangedNotification
{
    // free cache memory if user has not authorized access
    if (self.authorizationStatus != ECAuthorizationStatusAuthorized) {
        [self.eventCache invalidateCache];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECEventStoreProxyAuthorizationStatusChangedNotification object:nil];
}

- (void)postCalendarChangedNotification
{
    [self.eventCache invalidateCache];
    [[NSNotificationCenter defaultCenter] postNotificationName:ECEventStoreProxyCalendarChangedNotification object:nil];
}


#pragma mark - Calendars

- (NSArray*)calendars
{
    return [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
}

- (EKCalendar*)defaultCalendar
{
    return self.eventStore.defaultCalendarForNewEvents;
}

- (EKCalendar*)calendarWithIdentifier:(NSString *)identifier
{
    EKCalendar* calendar = [self.eventStore calendarWithIdentifier:identifier];
    return calendar;
}

#pragma mark - Loading User Events

- (BOOL)validateStartDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    if (!startDate) {
        DDLogError(@"Invalid Event Dates: Start date is nil");
        return NO;
    }
    
    if (!endDate) {
        DDLogError(@"Invalid Event Dates: End date is nil");
        return NO;
    }
    
    if ([startDate compare:endDate] != NSOrderedAscending) {
        DDLogError(@"Invalid Event Dates: Start date must be prior to end date");
        return NO;
    }
    
    return YES;
}

- (NSArray*)eventsFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    return [self.eventCache eventsFrom:startDate to:endDate in:nil];
}

- (NSArray*)eventsFrom:(NSDate *)startDate to:(NSDate *)endDate in:(NSArray *)calendars
{
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
            NSArray* events = [self.eventCache eventsFrom:startDate to:endDate in:calendars];
            return events;
        }
    }
}

#pragma mark - Editing Events

- (EKEvent*)createEvent
{
    EKEvent* event = [EKEvent eventWithEventStore:self.eventStore];
    event.calendar = self.defaultCalendar;
    
    return event;
}

- (BOOL)saveEvent:(EKEvent *)event span:(EKSpan)span
{
    if (!event) {
        DDLogWarn(@"Attempting to save nil event");
        return NO;
    }
    
    NSError* err;
    BOOL result = [self.eventStore saveEvent:event span:span commit:YES error:&err];
    
    // event identifiers cannot be relied upon after removal so cache should be reset
    [self.eventCache invalidateCache];
    
    if (err) {
        DDLogError(@"Failed to save event with error: %@", err);
    }
    
    return result;
}

- (BOOL)removeEvent:(EKEvent *)event span:(EKSpan)span
{
    if (!event) {
        DDLogWarn(@"Attempting to remove nil event");
        return NO;
    }
    
    NSError* err;
    BOOL result = [self.eventStore removeEvent:event span:span commit:YES error:&err];
    
    // event identifiers cannot be relied upon after removal so cache should be reset
    [self.eventCache invalidateCache];
    
    if (err) {
        DDLogError(@"Failed to remove event with error: %@", err);
    }
    
    return result;
}


#pragma mark - Managing Calendar Access

- (void)requestAccessToEvents
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError* err) {
        if (!err) {
            DDLogInfo(@"Calendar authorization status changed");
            [self postAuthorizationStatusChangedNotification];
        } else {
            DDLogError(@"Error requesting calendar authorization: %@", err);
        }
    }];
}


#pragma mark - Event caching

- (NSArray*)storedEventsFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    NSPredicate* eventsPredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    return [self.eventStore eventsMatchingPredicate:eventsPredicate];
}

- (void)flushCache
{
    self.eventCache = nil;
}


@end
