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
    ECAlarmTypeOffsetAbsoluteDate,
};

@interface ECAlarm : NSObject

@property (nonatomic, readonly) ECAlarmType type;
@property (nonatomic, strong) EKAlarm* __nullable ekAlarm;
@property (nonatomic, strong, readonly) NSString* __nonnull localizedName;

- (nonnull instancetype)initWithEKAlarm:(nonnull EKAlarm*)ekAlarm;

@end
