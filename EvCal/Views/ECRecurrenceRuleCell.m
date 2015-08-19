//
//  ECRecurrenceRuleCell.m
//  EvCal
//
//  Created by Tom on 8/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECRecurrenceRuleCell.h"
#import "ECDualViewSwitcher.h"
#import "ECRecurrenceRule.h"
@import EventKit;

@interface ECRecurrenceRuleCell() <UIPickerViewDataSource, UIPickerViewDelegate, ECDualViewSwitcherDatasource, ECDualViewSwitcherDelegate>

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* infoLabel;



@property (nonatomic, weak) IBOutlet ECDualViewSwitcher* pickerContainerView;
@property (nonatomic, weak, readwrite) UIPickerView* definedRecurrenceRulesPicker;
@property (nonatomic, weak, readwrite) UIPickerView* customRecurrenceRulesPicker;

@property (nonatomic, strong) NSArray* definedRecurrenceRules;
@property (nonatomic, strong) NSArray* customRuleTimeUnitNames;
@end

@implementation ECRecurrenceRuleCell

#pragma mark - Lifecycle and Properties

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    self.pickerContainerView.backgroundColor = [UIColor whiteColor];
    self.pickerContainerView.switcherDelegate = self;
    self.pickerContainerView.switcherDatasource = self;
    [self setupPickerViews];
}

- (void)setupPickerViews
{
    UIPickerView* definedRecurrenceRulesPicker = [[UIPickerView alloc] init];
    UIPickerView* customRecurrenceRulesPicker = [[UIPickerView alloc] init];
    
    definedRecurrenceRulesPicker.dataSource = self;
    definedRecurrenceRulesPicker.delegate = self;
    customRecurrenceRulesPicker.dataSource = self;
    customRecurrenceRulesPicker.delegate = self;
    
    self.definedRecurrenceRulesPicker = definedRecurrenceRulesPicker;
    self.customRecurrenceRulesPicker = customRecurrenceRulesPicker;
    // picker container will add pickers to its subviews
    self.pickerContainerView.primaryView = self.definedRecurrenceRulesPicker;
    self.pickerContainerView.secondaryView = self.customRecurrenceRulesPicker;
}

- (NSArray*)definedRecurrenceRules
{
    if (!_definedRecurrenceRules) {
        _definedRecurrenceRules = [self createDefinedRecurrenceRules];
    }
    
    return _definedRecurrenceRules;
}

- (NSArray*)customRuleTimeUnitNames
{
    if (!_customRuleTimeUnitNames) {
        _customRuleTimeUnitNames = [self createCustomRuleTimeUnitNames];
    }
    
    return _customRuleTimeUnitNames;
}

- (ECRecurrenceRule*)recurrenceRule
{
    if (self.pickerContainerView.visibleView == self.definedRecurrenceRulesPicker) {
        NSInteger selectedRow = [self.definedRecurrenceRulesPicker selectedRowInComponent:0];
        return self.definedRecurrenceRules[selectedRow];
    } else {
        NSInteger intervalRow = [self.customRecurrenceRulesPicker selectedRowInComponent:kCustomRuleIntervalComponent];
        NSInteger frequencyRow = [self.customRecurrenceRulesPicker selectedRowInComponent:kCustomRuleFrequencyComponent];
        ECRecurrenceRule* rule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:[self frequencyForRow:frequencyRow]
                                                                            interval:[self intervalForCustomRuleAtRow:intervalRow]];
        
        return rule;
    }
}

- (void)setRecurrenceRule:(ECRecurrenceRule *)recurrenceRule
{
    if (recurrenceRule.type == ECRecurrenceRuleTypeCustom) {
        [self.pickerContainerView switchToSecondayView:NO]; // secondary view is custom rule picker
        
        [self.customRecurrenceRulesPicker selectRow:[self rowForInterval:recurrenceRule.rule.interval] inComponent:kCustomRuleIntervalComponent animated:NO];
        [self.customRecurrenceRulesPicker selectRow:[self rowForFrequency:recurrenceRule.rule.frequency] inComponent:kCustomRuleFrequencyComponent animated:NO];
    } else {
        [self.pickerContainerView switchToPrimaryView:NO]; // primary view is defined rule picker
        
        [self.definedRecurrenceRulesPicker selectRow:[self rowForDefinedRecurrenceRuleType:recurrenceRule.type] inComponent:0 animated:NO];
    }
    
    [self updateInfoLabel];
}

- (NSInteger)rowForDefinedRecurrenceRuleType:(ECRecurrenceRuleType)type
{
    switch (type) {
        case ECRecurrenceRuleTypeNone:
            return kNoneRecurrenceRuleRow;
            
        case ECRecurrenceRuleTypeDaily:
            return kDailyRecurrenceRuleRow;
            
        case ECRecurrenceRuleTypeWeekdays:
            return kWeekdaysRecurrenceRuleRow;
            
        case ECRecurrenceRuleTypeWeekly:
            return kWeeklyRecurrenceRuleRow;
            
        case ECRecurrenceRuleTypeMonthly:
            return kMonthlyRecurrenceRuleRow;
            
        case ECRecurrenceRuleTypeYearly:
            return kYearlyRecurrenceRuleRow;
            
        case ECRecurrenceRuleTypeCustom:
            return 0;
    }
}

- (NSInteger)intervalForCustomRuleAtRow:(NSInteger)row
{
    // The starting value for custom rules is 2
    return row + 2;
}

- (NSInteger)rowForInterval:(NSInteger)interval
{
    return interval - 2;
}

- (EKRecurrenceFrequency)frequencyForRow:(NSInteger)row
{
    switch (row) {
        case kDailyFrequencyRow:
            return EKRecurrenceFrequencyDaily;
            
        case kWeeklyFrequencyRow:
            return EKRecurrenceFrequencyWeekly;
            
        case kMonthlyFrequencyRow:
            return EKRecurrenceFrequencyMonthly;
            
        case kYearlyFrequencyRow:
            return EKRecurrenceFrequencyYearly;
            
        default:
            return EKRecurrenceFrequencyDaily;
    }
}

- (NSInteger)rowForFrequency:(EKRecurrenceFrequency)frequency
{
    switch (frequency) {
        case EKRecurrenceFrequencyDaily:
            return kDailyFrequencyRow;
            
        case EKRecurrenceFrequencyWeekly:
            return kWeeklyFrequencyRow;
            
        case EKRecurrenceFrequencyMonthly:
            return kMonthlyFrequencyRow;
            
        case EKRecurrenceFrequencyYearly:
            return kYearlyFrequencyRow;
    }
}

#pragma mark - Recurrence Rules

- (NSArray*)createDefinedRecurrenceRules
{
    return @[[ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeNone],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly]];
}

- (NSArray*)createCustomRuleTimeUnitNames
{
    return @[NSLocalizedString(@"ECRecurrenceRuleCell.Days", @"The event should repeat after a given number of days"),
             NSLocalizedString(@"ECRecurrenceRuleCell.Weeks", @"The event should repeat after a given number of weeks"),
             NSLocalizedString(@"ECRecurrenceRuleCell.Months", @"The event should repeat after a given number of months"),
             NSLocalizedString(@"ECRecurrenceRuleCell.Years", @"The event should repeat after a given number of years")];
}


#pragma mark - ECDualViewSwitcher Delegate and Datasource

- (NSString*)titleForPrimaryView
{
    return NSLocalizedString(@"ECRecurrenceRuleCell.Custom", @"Switch to custom rule selection mode");
}

- (NSString*)titleForSecondaryView
{
    return NSLocalizedString(@"ECRecurrenceRuleCell.Basic", @"Switch to basic rule selection mode");
}

- (void)dualViewSwitcher:(nonnull ECDualViewSwitcher *)switcher didSwitchViewToVisible:(nullable UIView *)view
{
    [self informDelegateThatRecurrenceRuleWasUpdated];
    
    [self updateInfoLabel];
}

- (void)updateInfoLabel
{
    self.infoLabel.text = self.recurrenceRule.localizedName;
}

#pragma mark - UIPickerView Delegate and Data source

const static NSInteger kCustomRuleIntervalComponent =   0;
const static NSInteger kCustomRuleFrequencyComponent =  1;

const static NSInteger kDailyFrequencyRow =             0;
const static NSInteger kWeeklyFrequencyRow =            1;
const static NSInteger kMonthlyFrequencyRow =           2;
const static NSInteger kYearlyFrequencyRow =            3;

const static NSInteger kNoneRecurrenceRuleRow =         0;
const static NSInteger kDailyRecurrenceRuleRow =        1;
const static NSInteger kWeekdaysRecurrenceRuleRow =     2;
const static NSInteger kWeeklyRecurrenceRuleRow =       3;
const static NSInteger kMonthlyRecurrenceRuleRow =      4;
const static NSInteger kYearlyRecurrenceRuleRow =       5;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.definedRecurrenceRulesPicker) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.definedRecurrenceRulesPicker) {
        return [self numberOfRowsInDefinedRecurrenceRulesPicker];
    } else {
        return [self numberOfRowsInCustomRecurrenceRulesPicker:component];
    }
}

- (NSInteger)numberOfRowsInDefinedRecurrenceRulesPicker
{
    return self.definedRecurrenceRules.count;
}

- (NSInteger)numberOfRowsInCustomRecurrenceRulesPicker:(NSInteger)component
{
    if (component == kCustomRuleIntervalComponent) {
        return [self numberOfRowsInCustomRowCountComponent];
    } else {
        return [self numberOfRowsInCustomRowTimeUnitComponent];
    }
}

- (NSInteger)numberOfRowsInCustomRowCountComponent
{
    return 365 - 2;
}

- (NSInteger)numberOfRowsInCustomRowTimeUnitComponent
{
    return self.customRuleTimeUnitNames.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.definedRecurrenceRulesPicker) {
        return [self definedRecurrenceRuleTitleForRow:row forComponent:component];
    } else {
        return [self customRecurrenceRuleTitleForRow:row forComponent:component];
    }
}

- (NSString*)definedRecurrenceRuleTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ECRecurrenceRule* recurrenceRule = self.definedRecurrenceRules[row];
    return recurrenceRule.localizedName;
}

- (NSString*)customRecurrenceRuleTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == kCustomRuleIntervalComponent) {
        return [self customCountTitleForRow:row];
    } else {
        return [self timeUnitTitleForRow:row];
    }
}

- (NSString*)customCountTitleForRow:(NSInteger)row
{
    return [NSString stringWithFormat:@"%lu", [self intervalForCustomRuleAtRow:row]];
}

- (NSString*)timeUnitTitleForRow:(NSInteger)row
{
    return self.customRuleTimeUnitNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self informDelegateThatRecurrenceRuleWasUpdated];
    
    self.infoLabel.text = self.recurrenceRule.localizedName;
}

- (void)informDelegateThatRecurrenceRuleWasUpdated
{
    if ([self.recurrenceRuleDelegate respondsToSelector:@selector(recurrenceCell:didSelectRecurrenceRule:)]) {
        [self.recurrenceRuleDelegate recurrenceCell:self didSelectRecurrenceRule:self.recurrenceRule];
    }
}

@end
