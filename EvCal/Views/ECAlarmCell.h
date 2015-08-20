//
//  ECAlarmCell.h
//  EvCal
//
//  Created by Tom on 8/18/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECAlarm;
@class ECAlarmCell;

//------------------------------------------------------------------------------
// @name ECAlarmCellDelegate
//------------------------------------------------------------------------------

@protocol ECAlarmCellDelegate <NSObject>

@optional
/**
 *  Notifies the receiver that the alarm cell has selected an alarm value.
 *
 *  @param cell  The cell which selected an alarm
 *  @param alarm The alarm selected by the cell
 */
- (void)alarmCell:(ECAlarmCell*)cell didSelectAlarm:(ECAlarm*)alarm;

@end

@interface ECAlarmCell : UITableViewCell

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The cell's current alarm value. Changing this will update the cell's UI
// accordingly.
@property (nonatomic, strong) ECAlarm* alarm;

// The initial value for the cell's date picker. This value should only be set
// if the alarm property does not already have an absolute date specified.
@property (nonatomic, strong) NSDate* defaultDate;
// The earliest allowed date for an alarm
@property (nonatomic, strong) NSDate* minimumDate; // default is nil
// The latest allowed date for an alarm
@property (nonatomic, strong) NSDate* maximumDate; // default is nil

// The delegate to receive alarm change notifications
@property (nonatomic, weak) id<ECAlarmCellDelegate> alarmDelegate;

@end
