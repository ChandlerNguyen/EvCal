//
//  ECAlarmFormatter.m
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECAlarmFormatter.h"

@interface ECAlarmFormatter()

@property (nonatomic, strong) NSDateFormatter* dateFormatter;

@property (nonatomic, strong, readwrite) NSString* __nonnull noneAlarmLocalizedName; // None
@property (nonatomic, strong, readwrite) NSString* __nonnull quarterHourAlarmLocalizedName; // 15 Minutes
@property (nonatomic, strong, readwrite) NSString* __nonnull halfHourLocalizedName; // 30 Minutes
@property (nonatomic, strong, readwrite) NSString* __nonnull oneHourLocalizedName; // One Hour
@property (nonatomic, strong, readwrite) NSString* __nonnull twoHoursLocalizedName; // Two Hours
@property (nonatomic, strong, readwrite) NSString* __nonnull sixHoursLocalizedName; // Six Hours
@property (nonatomic, strong, readwrite) NSString* __nonnull oneDayLocalizedName; // One Day
@property (nonatomic, strong, readwrite) NSString* __nonnull twoDaysLocalizedName; // Two Days
@property (nonatomic, strong, readwrite) NSString* __nonnull customOffsetLocalizedName; // Custom
@property (nonatomic, strong, readwrite) NSString* __nonnull absoluteDateLocalizedName; // Specific Date
@property (nonatomic, strong, readwrite) NSArray* __nonnull localizedNames;

@end

@implementation ECAlarmFormatter

+ (instancetype)defaultFormatter
{
    static ECAlarmFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[ECAlarmFormatter alloc] init];
    });
    
    return formatter;
}

- (NSDateFormatter*)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    return _dateFormatter;
}

- (NSString*)noneAlarmLocalizedName
{
    if (!_noneAlarmLocalizedName) {
        _noneAlarmLocalizedName = NSLocalizedString(@"ECAlarm.None", @"The event has no alarm");
    }
    
    return _noneAlarmLocalizedName;
}

- (NSString*)quarterHourAlarmLocalizedName
{
    if (!_quarterHourAlarmLocalizedName) {
        _quarterHourAlarmLocalizedName = NSLocalizedString(@"ECAlarm.15 Minutes Before", @"The alarm occurs 15 minutes before the event's start date");
    }
    
    return _quarterHourAlarmLocalizedName;
}

- (NSString*)halfHourLocalizedName
{
    if (!_halfHourLocalizedName) {
        _halfHourLocalizedName = NSLocalizedString(@"ECAlarm.30 Minutes Before", @"The alarm occurs 30 minutes before the event's start date");
    }
    
    return _halfHourLocalizedName;
}

- (NSString*)oneHourLocalizedName
{
    if (!_oneHourLocalizedName) {
        _oneHourLocalizedName = NSLocalizedString(@"ECAlarm.1 Hour Before", @"The alarm occurs one hour before the event's start date");
    }
    
    return _oneHourLocalizedName;
}

- (NSString*)twoHoursLocalizedName
{
    if (!_twoHoursLocalizedName) {
        _twoHoursLocalizedName = NSLocalizedString(@"ECAlarm.2 Hours Before", @"The alarm occurs two hours before the event's start date");
    }
    
    return _twoHoursLocalizedName;
}

- (NSString*)sixHoursLocalizedName
{
    if (!_sixHoursLocalizedName) {
        _sixHoursLocalizedName = NSLocalizedString(@"ECAlarm.6 Hours Before", @"The alarm occurs six horus before the event's start date");
    }
    
    return _sixHoursLocalizedName;
}

- (NSString*)oneDayLocalizedName
{
    if (!_oneDayLocalizedName) {
        _oneDayLocalizedName = NSLocalizedString(@"ECAlarm.1 Day Before", @"The alarm occurs one day before the event's start date");
    }
    
    return _oneDayLocalizedName;
}

- (NSString*)twoDaysLocalizedName
{
    if (!_twoDaysLocalizedName) {
        _twoDaysLocalizedName = NSLocalizedString(@"ECAlarm.2 Days Before", @"THe alarm occurs two days before the event's start date");
    }
    
    return _twoDaysLocalizedName;
}

- (NSString*)customOffsetLocalizedName
{
    if (!_customOffsetLocalizedName) {
        _customOffsetLocalizedName = NSLocalizedString(@"ECAlarm.Custom", @"The alarm occurs at a user specified offset prior to the event's start date");
    }
    
    return _customOffsetLocalizedName;
}

- (NSString*)absoluteDateLocalizedName
{
    if (!_absoluteDateLocalizedName) {
        _absoluteDateLocalizedName = NSLocalizedString(@"ECAlarm.Specific Date", @"The alarm occurs at a date specified by the user");
    }
    
    return _absoluteDateLocalizedName;
}

- (NSArray*)localizedNames
{
    if (!_localizedNames) {
        _localizedNames = @[self.noneAlarmLocalizedName,
                            self.quarterHourAlarmLocalizedName,
                            self.halfHourLocalizedName,
                            self.oneHourLocalizedName,
                            self.twoHoursLocalizedName,
                            self.sixHoursLocalizedName,
                            self.oneDayLocalizedName,
                            self.twoDaysLocalizedName,
                            self.customOffsetLocalizedName,
                            self.absoluteDateLocalizedName];
    }
    
    return _localizedNames;
}

- (NSString*)localizedStringForAlarmType:(ECAlarmType)alarmType
{
    switch (alarmType) {
        case ECAlarmTypeNone:
            return self.noneAlarmLocalizedName;
            
        case ECAlarmTypeOffsetQuarterHour:
            return self.quarterHourAlarmLocalizedName;
            
        case ECAlarmTypeOffsetHalfHour:
            return self.halfHourLocalizedName;
            
        case ECAlarmTypeOffsetOneHour:
            return self.oneHourLocalizedName;
            
        case ECAlarmTypeOffsetTwoHours:
            return self.twoHoursLocalizedName;
            
        case ECAlarmTypeOffsetSixHours:
            return self.sixHoursLocalizedName;
            
        case ECAlarmTypeOffsetOneDay:
            return self.oneDayLocalizedName;
            
        case ECAlarmTypeOffsetTwoDays:
            return self.twoDaysLocalizedName;
            
        case ECAlarmTypeOffsetCustom:
            return self.customOffsetLocalizedName;
            
        case ECAlarmTypeAbsoluteDate:
            return self.absoluteDateLocalizedName;
    }
}

- (NSString*)localizedStringFromAlarm:(nonnull ECAlarm *)alarm
{
    if (alarm) {
        switch (alarm.type) {
            case ECAlarmTypeAbsoluteDate:
                return [self localizedStringFromAbsoluteDateAlarm:alarm];
                
            case ECAlarmTypeOffsetCustom:
                return [self localizedStringFromCustomAlarm:alarm];
                
            default:
                return [self localizedStringForAlarmType:alarm.type];
        }
    } else {
        return nil;
    }
}

- (NSString*)localizedStringFromAbsoluteDateAlarm:(ECAlarm*)alarm
{
    return [self.dateFormatter stringFromDate:alarm.ekAlarm.absoluteDate];
}

const static NSTimeInterval kMinuteTimeInterval = 60.0;
const static NSTimeInterval kHourTimeInterval = 60.0 * kMinuteTimeInterval;
const static NSTimeInterval kDayTimeInterval = 24 * kHourTimeInterval;

- (NSString*)localizedStringFromCustomAlarm:(ECAlarm*)alarm
{
    NSTimeInterval offset = alarm.ekAlarm.relativeOffset;
    NSInteger days = (NSInteger)(offset / kDayTimeInterval);
    offset -= (days * kDayTimeInterval);
    NSInteger hours = (NSInteger)(offset / kHourTimeInterval);
    offset -= (days * kHourTimeInterval);
    NSInteger minutes = (NSInteger)(offset / kMinuteTimeInterval);
    
    NSString* alarmDescription = [NSString stringWithFormat:NSLocalizedString(@"%lu Days, %lu Hours, %lu Minutes Before", @"Alarm occurs [days] Days, [hours] Hours, [minutes] Minutes prior to event"),
                                  days, hours, minutes];
    
    return alarmDescription;
}

@end
