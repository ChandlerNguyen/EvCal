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

@property (nonatomic, strong, readwrite) NSString* __nonnull noneAlarmLocalizedName; // None
@property (nonatomic, strong, readwrite) NSString* __nonnull quarterHourAlarmLocalizedName; // 15 Minutes Before
@property (nonatomic, strong, readwrite) NSString* __nonnull halfHourLocalizedName; // 30 Minutes Before
@property (nonatomic, strong, readwrite) NSString* __nonnull oneHourLocalizedName; // One Hour Before
@property (nonatomic, strong, readwrite) NSString* __nonnull twoHoursLocalizedName; // Two Hours Before
@property (nonatomic, strong, readwrite) NSString* __nonnull sixHoursLocalizedName; // Six Hours Before
@property (nonatomic, strong, readwrite) NSString* __nonnull oneDayLocalizedName; // One Day Before
@property (nonatomic, strong, readwrite) NSString* __nonnull twoDaysLocalizedName; // Two Days Before
@property (nonatomic, strong, readwrite) NSString* __nonnull customOffsetLocalizedName; // [Offset] Before
@property (nonatomic, strong, readwrite) NSString* __nonnull absoluteDateLocalizedName; // July 4th, 2015, 10:00PM
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
        _oneHourLocalizedName = NSLocalizedString(@"ECAlarm.One Hour Before", @"The alarm occurs one hour before the event's start date");
    }
    
    return _halfHourLocalizedName;
}

- (NSString*)twoHoursLocalizedName
{
    if (!_twoHoursLocalizedName) {
        _twoHoursLocalizedName = NSLocalizedString(@"ECAlarm.Two Hours Before", @"The alarm occurs two hours before the event's start date");
    }
    
    return _twoHoursLocalizedName;
}

- (NSString*)sixHoursLocalizedName
{
    if (!_sixHoursLocalizedName) {
        _sixHoursLocalizedName = NSLocalizedString(@"ECAlarm.Six Hours Before", @"The alarm occurs six horus before the event's start date");
    }
    
    return _sixHoursLocalizedName;
}

- (NSString*)oneDayLocalizedName
{
    if (!_oneDayLocalizedName) {
        _oneDayLocalizedName = NSLocalizedString(@"ECAlarm.One Day Before", @"The alarm occurs one day before the event's start date");
    }
    
    return _oneDayLocalizedName;
}

- (NSString*)twoDaysLocalizedName
{
    if (!_twoDaysLocalizedName) {
        _twoDaysLocalizedName = NSLocalizedString(@"ECAlarm.TWo Days Before", @"THe alarm occurs two days before the event's start date");
    }
    
    return _twoDaysLocalizedName;
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
                            self.twoDaysLocalizedName];
    }
    
    return _localizedNames;
}

- (NSString*)localizedStringFromAlarm:(nonnull ECAlarm *)alarm
{
    if (alarm) {
        if (alarm.type == ECAlarmTypeAbsoluteDate) {
            return [self localizedStringFromAbsoluateDateAlarm:alarm];
        } else {
            return [self localizedStringFromRelativeOffsetAlarm:alarm];
        }
    } else {
        return nil;
    }
}

- (NSString*)localizedStringFromAbsoluateDateAlarm:(ECAlarm*)alarm
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    return [formatter stringFromDate:alarm.ekAlarm.absoluteDate];
}

- (NSString*)localizedStringFromRelativeOffsetAlarm:(ECAlarm*)alarm
{
    switch (alarm.type) {
        case ECAlarmTypeNone:
            return self.noneAlarmLocalizedName;
            
        case ECAlarmTypeOffsetQuarterHour:
            return self.quarterHourAlarmLocalizedName;
            
        case ECAlarmTypeOffsetHalfHour:
            return self.halfHourLocalizedName;
            
        case ECAlarmTypeOffsetHour:
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
            return [self localizedStringFromCustomOffsetAlarm:alarm];
            
        default:
            return nil;
    }
}

const static NSTimeInterval kMinuteTimeInterval = 60;
const static NSTimeInterval kHourTimeInterval = 60 * kMinuteTimeInterval;

- (NSString*)localizedStringFromCustomOffsetAlarm:(ECAlarm*)alarm
{
    NSTimeInterval offset = alarm.ekAlarm.relativeOffset;
    NSInteger hours = (NSInteger)(offset / (kHourTimeInterval));
    offset -= (hours * kHourTimeInterval);
    
    NSInteger minutes = (NSInteger)(offset / kMinuteTimeInterval);
    
    // use explicit if statements so static strings can be fed to genstrings
    if (hours != 0 && minutes != 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"ECAlarm.%lu Hours, %lu Minutes Before", @"The alarm occurs [hours] hours and [minutes] minutes before the event start date"), hours, minutes];
    } else if (hours != 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"ECAlarm.%lu Hours Before", @"The alarm occurs [hours] hours before the event start date"), hours];
    } else if (minutes != 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"ECAlarm.%lu Minutes Before", @"The alarm occurs [minutes] minutes before the event start date"), minutes];
    } else {
        return NSLocalizedString(@"ECAlarm.When Event Begins", @"The alarm occurs at the same time as the event start date");
    }
}

@end
