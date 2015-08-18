//
//  ECAlarmCell.m
//  EvCal
//
//  Created by Tom on 8/18/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECAlarmCell.h"
#import "ECDualViewSwitcher.h"
#import "ECAlarm.h"

@interface ECAlarmCell() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* infoLabel;
@property (nonatomic, weak) IBOutlet ECDualViewSwitcher* pickerContainerView;
@property (nonatomic, weak) UIPickerView* offsetAlarmPicker;
@property (nonatomic, weak) UIDatePicker* absoluteDatePicker;

@property (nonatomic, strong) NSArray* offsetAlarms;

@end

@implementation ECAlarmCell

#pragma mark - Lifecycle and Properties

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    [self setupPickers];
}

- (void)setupPickers
{
    UIPickerView* offsetAlarmPicker = [[UIPickerView alloc] init];
    UIDatePicker* absoluteDatePicker = [[UIDatePicker alloc] init];
    
    offsetAlarmPicker.dataSource = self;
    offsetAlarmPicker.delegate = self;
    [absoluteDatePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.offsetAlarmPicker = offsetAlarmPicker;
    self.absoluteDatePicker = absoluteDatePicker;
    
    [self.pickerContainerView setPrimaryView:offsetAlarmPicker];
    [self.pickerContainerView setSecondaryView:absoluteDatePicker];
}

- (NSArray*)offsetAlarms
{
    if (!_offsetAlarms) {
        _offsetAlarms = [self createOffsetAlarms];
    }
    
    return _offsetAlarms;
}

- (NSArray*)createOffsetAlarms
{
    return @[[ECAlarm alarmWithType:ECAlarmTypeNone],
             [ECAlarm alarmWithType:ECAlarmTypeOffsetQuarterHour],
             [ECAlarm alarmWithType:ECAlarmTypeOffsetHalfHour],
             [ECAlarm alarmWithType:ECAlarmTypeOffsetOneHour],
             [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoHours],
             [ECAlarm alarmWithType:ECAlarmTypeOffsetSixHours],
             [ECAlarm alarmWithType:ECAlarmTypeOffsetOneDay],
             [ECAlarm alarmWithType:ECAlarmTypeOffsetTwoDays]];
}

- (ECAlarm*)alarm
{
    if (self.pickerContainerView.visibleView == self.offsetAlarmPicker) {
        NSInteger alarmRow = [self.offsetAlarmPicker selectedRowInComponent:0];
        ECAlarm* alarm = self.offsetAlarms[alarmRow];
        return alarm;
    } else {
        ECAlarm* alarm = [ECAlarm alarmWithDate:self.absoluteDatePicker.date];
        return alarm;
    }
}

- (void)setAlarm:(ECAlarm *)alarm
{
    if (alarm.type == ECAlarmTypeAbsoluteDate) {
        
    } else {
        if (alarm.type == ECAlarmTypeOffsetCustom) {
            [self addCustomAlarmToOffsetAlarms:alarm];
        }
        
        NSInteger alarmRow = [self rowForOffsetAlarm:alarm];
        [self.offsetAlarmPicker selectRow:alarmRow inComponent:0 animated:NO];
        // Offset alarm picker is primary view
        [self.pickerContainerView switchToPrimaryView:NO];
    }
}

- (void)addCustomAlarmToOffsetAlarms:(ECAlarm*)alarm
{
    NSMutableArray* mutableOffsetAlarms = [self.offsetAlarms mutableCopy];
    [mutableOffsetAlarms addObject:alarm];
    self.offsetAlarms = [mutableOffsetAlarms copy];
    
    [self.offsetAlarmPicker reloadComponent:0];
}

- (NSInteger)rowForOffsetAlarm:(ECAlarm*)alarm
{
    switch (alarm.type) {
        case ECAlarmTypeNone:
            return kAlarmNoneRow;
            
        case ECAlarmTypeOffsetQuarterHour:
            return kAlarmOffsetQuarterHourRow;
            
        case ECAlarmTypeOffsetHalfHour:
            return kAlarmOffsetHalfHourRow;
            
        case ECAlarmTypeOffsetOneHour:
            return kAlarmOffsetOneHourRow;
            
        case ECAlarmTypeOffsetTwoHours:
            return kAlarmOffsetTwoHoursRow;
            
        case ECAlarmTypeOffsetSixHours:
            return kAlarmOffsetSixHoursRow;
            
        case ECAlarmTypeOffsetOneDay:
            return kAlarmOffsetOneDayRow;
            
        case ECAlarmTypeOffsetTwoDays:
            return kAlarmOffsetTwoDaysRow;
            
        case ECAlarmTypeOffsetCustom:
            return kAlarmOffsetCustomRow;
            
        default:
            // Crash the program if an absolute date is passed to this method
            return -1;
    }
}

#pragma mark - UI Events

- (void)datePickerValueChanged:(UIDatePicker*)sender
{
    DDLogDebug(@"Date picker value changed: %@", sender.date);
}


#pragma mark - UIPickerView delegate and data source

const static NSInteger kAlarmNoneRow              = 0;
const static NSInteger kAlarmOffsetQuarterHourRow = 1;
const static NSInteger kAlarmOffsetHalfHourRow =    2;
const static NSInteger kAlarmOffsetOneHourRow =     3;
const static NSInteger kAlarmOffsetTwoHoursRow =    4;
const static NSInteger kAlarmOffsetSixHoursRow =    5;
const static NSInteger kAlarmOffsetOneDayRow =      6;
const static NSInteger kAlarmOffsetTwoDaysRow =     7;
const static NSInteger kAlarmOffsetCustomRow =      8;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.offsetAlarms.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ECAlarm* alarm = self.offsetAlarms[row];
    return alarm.localizedName;
}

@end
