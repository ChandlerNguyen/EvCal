//
//  ECEditEventRecurrenceCustomRuleViewController.m
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

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
}

- (NSArray*)frequencyNames
{
    if (!_frequencyNames) {
        NSMutableArray* mutableRuleNames = [[ECRecurrenceRuleFormatter defaultFormatter].ruleNames mutableCopy];
        [mutableRuleNames removeObject:[ECRecurrenceRuleFormatter defaultFormatter].noneRuleName];
        [mutableRuleNames removeObject:[ECRecurrenceRuleFormatter defaultFormatter].customRuleName];
        
        _frequencyNames = [mutableRuleNames copy];
    }
    
    return _frequencyNames;
}

#pragma mark - UIPickerView data source and delegate

const static NSInteger kRecurrencePickerComponentsCount =       2;
const static NSInteger kRecurrencePickerIntervalComponent =     0;

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
        return [NSString stringWithFormat:@"%lu", (long)row];
    } else {
        return self.frequencyNames[row];
    }
}

@end
