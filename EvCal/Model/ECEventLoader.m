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

@property (nonatomic) EKEventStore* eventStore;

@end

@implementation ECEventLoader

- (EKEventStore*)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
        
        [self requestAccessToEvents];
    }
    
    return _eventStore;
}


#pragma mark - Accessing User Events

- (void)requestAccessToEvents
{
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError* err) {
        if (granted) {
            
        }
    }];
}

@end
