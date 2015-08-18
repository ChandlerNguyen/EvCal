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


#pragma mark - UI Events

- (void)datePickerValueChanged:(UIDatePicker*)sender
{
    DDLogDebug(@"Date picker value changed: %@", sender.date);
}


#pragma mark - UIPickerView delegate and data source

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
