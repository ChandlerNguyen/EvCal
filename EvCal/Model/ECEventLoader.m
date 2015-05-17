//
//  ECEventLoader.m
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECLog.h"
#import "ECEventLoader.h"
@interface ECEventLoader()

@property (nonatomic, readwrite) ECAuthorizationStatus authorizationStatus;

@property (nonatomic, strong) EKEventStore* eventStore;

@end

@implementation ECEventLoader

#pragma mark - Lifecycle and Properties

+ (instancetype)sharedInstance
{
    __strong static ECEventLoader* _loader = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _loader = [[ECEventLoader alloc] init];
    });
    
    return _loader;
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
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
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


#pragma mark - Loading User Events

- (NSArray*)loadEventsFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    return [self loadEventsFrom:startDate to:endDate in:nil];
}

- (NSArray*)loadEventsFrom:(NSDate *)startDate to:(NSDate *)endDate in:(NSArray *)calendars
{
    switch (self.authorizationStatus) {
        case ECAuthorizationStatusNotDetermined:
            [self requestAccessToEvents];
            return nil;
            
        case ECAuthorizationStatusDenied:
            return nil;
        
        case ECAuthorizationStatusAuthorized: {
            NSPredicate* dateRangePredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendars];
            NSArray* events = [self.eventStore eventsMatchingPredicate:dateRangePredicate];
            
            return events;
        }
    }
}

#pragma mark - Managing Calendar Access

- (void)requestAccessToEvents
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError* err) {
        if (!err) {
            [self postAuthorizationStatusChangedNotification];
        }
    }];
}

- (void)postAuthorizationStatusChangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ECEventLoaderAuthorizationStatusChangedNotification object:nil];
}

@end
