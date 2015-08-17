//
//  ECEditEventRecurrenceRuleCell.m
//  EvCal
//
//  Created by Tom on 8/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEditEventRecurrenceRuleCell.h"
#import "ECDualViewSwitcher.h"
#import "ECRecurrenceRule.h"
@import EventKit;

@interface ECEditEventRecurrenceRuleCell() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* infoLabel;

@property (nonatomic, weak) IBOutlet UIButton* switchPickerButton;

@property (nonatomic, weak) IBOutlet ECDualViewSwitcher* pickerContainerView;
@property (nonatomic, weak, readwrite) UIPickerView* definedRecurrenceRulesPicker;
@property (nonatomic, weak, readwrite) UIPickerView* customRecurrenceRulesPicker;

@property (nonatomic, strong) NSArray* definedRecurrenceRules;
@property (nonatomic, strong) NSArray* customRuleTimeUnitNames;
@end

@implementation ECEditEventRecurrenceRuleCell

#pragma mark - Lifecycle and Properties

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    self.pickerContainerView.backgroundColor = [UIColor whiteColor];
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

- (NSInteger)intervalForCustomRuleAtRow:(NSInteger)row
{
    // The starting value for custom rules is 2
    return row + 2;
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


#pragma mark - UI Events

- (IBAction)switchPickerButtonTapped:(UIButton*)sender
{
    [self.pickerContainerView switchView:YES];
}


#pragma mark - UIPickerView Delegate and Data source

const static NSInteger kCustomRuleIntervalComponent =   0;
const static NSInteger kCustomRuleFrequencyComponent =  1;

const static NSInteger kDailyFrequencyRow =             0;
const static NSInteger kWeeklyFrequencyRow =            1;
const static NSInteger kMonthlyFrequencyRow =           2;
const static NSInteger kYearlyFrequencyRow =            3;

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

@end
