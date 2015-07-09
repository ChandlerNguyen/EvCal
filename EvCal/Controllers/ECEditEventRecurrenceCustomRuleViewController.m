//
//  ECEditEventRecurrenceCustomRuleViewController.m
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import EventKit;
#import "ECEditEventRecurrenceCustomRuleViewController.h"
#import "ECRecurrenceRuleFormatter.h"

@interface ECEditEventRecurrenceCustomRuleViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) IBOutlet UILabel* repeatLabel;
@property (nonatomic, weak) IBOutlet UIPickerView* recurrenceRulePicker;

@property (nonatomic, strong) NSArray* frequencyNames;

@end

@implementation ECEditEventRecurrenceCustomRuleViewController

#pragma mark - Lifecycle and Properties

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recurrenceRulePicker.delegate = self;
    self.recurrenceRulePicker.dataSource = self;
    
    [self.recurrenceRulePicker selectRow:[self rowForInterval:self.recurrenceRule.rule.interval] inComponent:kRecurrencePickerIntervalComponent animated:NO];
    [self.recurrenceRulePicker selectRow:[self rowForFrequency:self.recurrenceRule.rule.frequency] inComponent:kRecurrencePickerFrequencyComponent animated:NO];
    
    [self updateRecurrenceLabelWithRule:self.recurrenceRule];
}

- (void)updateRecurrenceLabelWithRule:(ECRecurrenceRule*)rule
{
    self.repeatLabel.text = [[ECRecurrenceRuleFormatter defaultFormatter] detailStringFromRecurrenceRule:rule];
}

- (NSArray*)frequencyNames
{
    if (!_frequencyNames) {
        NSMutableArray* mutableRuleNames = [[ECRecurrenceRuleFormatter defaultFormatter].ruleNames mutableCopy];
        [mutableRuleNames removeObject:[ECRecurrenceRuleFormatter defaultFormatter].noneRuleName];
        [mutableRuleNames removeObject:[ECRecurrenceRuleFormatter defaultFormatter].customRuleName];
        [mutableRuleNames removeObject:[ECRecurrenceRuleFormatter defaultFormatter].weekdaysRuleName];
        
        _frequencyNames = [mutableRuleNames copy];
    }
    
    return _frequencyNames;
}

#pragma mark - UIPickerView data source and delegate

const static NSInteger kRecurrencePickerComponentsCount =       2;
const static NSInteger kRecurrencePickerIntervalComponent =     0;
const static NSInteger kRecurrencePickerFrequencyComponent =    1;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return kRecurrencePickerComponentsCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == kRecurrencePickerIntervalComponent) {
        return 500;
    } else {
        return self.frequencyNames.count;
    }
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == kRecurrencePickerIntervalComponent) {
        return [NSString stringWithFormat:@"%lu", (long)[self intervalForPickerRow:row]];
    } else {
        return self.frequencyNames[row];
    }
}

- (NSInteger)intervalForPickerRow:(NSInteger)row
{
    return row + 1;
}

- (EKRecurrenceFrequency)frequencyForPickerRow:(NSInteger)row
{
    return (EKRecurrenceFrequency)row;
}

- (NSInteger)rowForFrequency:(EKRecurrenceFrequency)frequency
{
    return (NSInteger)frequency;
}

- (NSInteger)rowForInterval:(NSInteger)interval
{
    return interval - 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger intervalRow = [self.recurrenceRulePicker selectedRowInComponent:kRecurrencePickerIntervalComponent];
    NSInteger frequencyRow = [self.recurrenceRulePicker selectedRowInComponent:kRecurrencePickerFrequencyComponent];
    
    self.recurrenceRule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:[self frequencyForPickerRow:frequencyRow] interval:[self intervalForPickerRow:intervalRow]];
    [self updateRecurrenceLabelWithRule:self.recurrenceRule];
    [self informDelegateRecurrenceRuleWasSelected];
}

#pragma mark - Delegate

- (void)informDelegateRecurrenceRuleWasSelected
{
    if ([self.customRuleDelegate respondsToSelector:@selector(viewController:didSelectCustomRule:)]) {
        [self.customRuleDelegate viewController:self didSelectCustomRule:self.recurrenceRule];
    }
}

@end
