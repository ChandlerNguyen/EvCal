//
//  ECAlarm.m
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECAlarm.h"
@import EventKit;


@implementation ECAlarm

#pragma mark - Offset Constants

const static NSTimeInterval kQuarterHourTimeInterval =  60 * 15;
const static NSTimeInterval kHalfHourTimeInterval =     60 * 30;
const static NSTimeInterval kHourTimeInterval =         60 * 60;
const static NSTimeInterval kTwoHourTimeInterval =      60 * 60 * 2;
const static NSTimeInterval kSixHourTimeInterval =      60 * 60 * 6;
const static NSTimeInterval kOneDayTimeInterval =       60 * 60 * 24; // Using hard coded offset might cause problems during daylight savings time
const static NSTimeInterval kTwoDayTimeInterval =       60 * 60 * 24 * 2;

- (nonnull instancetype)initWithEKAlarm:(nullable EKAlarm *)ekAlarm
{
    self = [super init];
    if (self) {
        self.ekAlarm = ekAlarm;
    }
    
    return self;
}

+ (nonnull instancetype)alarmWithType:(ECAlarmType)type
{
    EKAlarm* ekAlarm = [self ekAlarmForType:type];
    
    ECAlarm* alarm = [[ECAlarm alloc] initWithEKAlarm:ekAlarm];
    
    return alarm;
}

+ (nullable EKAlarm*)ekAlarmForType:(ECAlarmType)type
{
    switch (type) {
        case ECAlarmTypeNone:
            return nil;
        case ECAlarmTypeOffsetQuarterHour:
            return [EKAlarm alarmWithRelativeOffset:kQuarterHourTimeInterval];
            
        case ECAlarmTypeOffsetHalfHour:
            return [EKAlarm alarmWithRelativeOffset:kHalfHourTimeInterval];
            
        case ECAlarmTypeOffsetHour:
            return [EKAlarm alarmWithRelativeOffset:kHourTimeInterval];
            
        case ECAlarmTypeOffsetTwoHours:
            return [EKAlarm alarmWithRelativeOffset:kTwoHourTimeInterval];
            
        case ECAlarmTypeOffsetSixHours:
            return [EKAlarm alarmWithRelativeOffset:kSixHourTimeInterval];
            
        case ECAlarmTypeOffsetOneDay:
            return [EKAlarm alarmWithRelativeOffset:kOneDayTimeInterval];
            
        case ECAlarmTypeOffsetTwoDays:
            return [EKAlarm alarmWithRelativeOffset:kTwoDayTimeInterval];
            
        case ECAlarmTypeOffsetCustom: {
            NSException* invalidArgumentException = [NSException exceptionWithName:NSInvalidArgumentException
                                                                            reason:@"Cannot create alarm with ECAlarmTypeCustom, Use intWithEKAlarm: method instead"
                                                                          userInfo:nil];
            @throw invalidArgumentException;
        }
            
        case ECAlarmTypeAbsoluteDate: {
            NSException* invalidArgumentException = [NSException exceptionWithName:NSInvalidArgumentException
                                                                            reason:@"Cannot create alarm with ECAlarmTypeAbsoluteDate, use initWithEKAlarm: method instead"
                                                                          userInfo:nil];
            @throw invalidArgumentException;
        }
    }
}

@end
