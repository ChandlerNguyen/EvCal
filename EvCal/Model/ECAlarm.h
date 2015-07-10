//
//  ECAlarm.h
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EKAlarm;

typedef NS_ENUM(NSInteger, ECAlarmType) {
    ECAlarmTypeNone,
    ECAlarmTypeOffsetQuarterHour,
    ECAlarmTypeOffsetHalfHour,
    ECAlarmTypeOffsetHour,
    ECAlarmTypeOffsetTwoHours,
    ECAlarmTypeOffsetSixHours,
    ECAlarmTypeOffsetOneDay,
    ECAlarmTypeOffsetTwoDays,
    ECAlarmTypeOffsetCustom,
    ECAlarmTypeAbsoluteDate,
};

@interface ECAlarm : NSObject

@property (nonatomic, readonly) ECAlarmType type;
@property (nonatomic, strong) EKAlarm* __nullable ekAlarm;
@property (nonatomic, strong, readonly) NSString* __nonnull localizedName;

- (nonnull instancetype)initWithEKAlarm:(nullable EKAlarm*)ekAlarm;
+ (nonnull instancetype)alarmWithType:(ECAlarmType)type;
+ (nonnull instancetype)alarmWithDate:(nonnull NSDate*)date;

@end
