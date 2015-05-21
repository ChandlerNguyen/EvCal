//
//  ECTestsEventQuery.h
//  EvCal
//
//  Created by Tom on 5/21/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import <Foundation/Foundation.h>

@interface ECTestsEventQuery : NSObject

@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;
@property (nonatomic, strong) EKCalendar* calendar;

@end
