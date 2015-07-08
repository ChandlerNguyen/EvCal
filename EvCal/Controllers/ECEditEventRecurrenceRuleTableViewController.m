//
//  ECEditEventRecurrenceRuleTableViewController.m
//  EvCal
//
//  Created by Tom on 7/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEditEventRecurrenceRuleTableViewController.h"
#import "ECRecurrenceRule.h"
#import "ECEventCustomRecurrenceRuleCell.h"

@interface ECEditEventRecurrenceRuleTableViewController ()

@property (nonatomic, strong) ECRecurrenceRule* ecRecurrenceRule;
@property (nonatomic, strong) NSArray* specificReccurenceRules;
@property (nonatomic, strong) ECRecurrenceRule* customRecurrenceRule;

@end

@implementation ECEditEventRecurrenceRuleTableViewController

- (void)viewDidLoad
{
    if (!self.ecRecurrenceRule) {
        self.ecRecurrenceRule = [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeNone];
    }
}

- (void)setRecurrenceRule:(EKRecurrenceRule *)recurrenceRule
{
    self.ecRecurrenceRule = [[ECRecurrenceRule alloc] initWithRecurrenceRule:recurrenceRule];
    [self.tableView reloadData];
}

- (EKRecurrenceRule*)recurrenceRule
{
    return self.ecRecurrenceRule.rule;
}


- (ECRecurrenceRule*)customRecurrenceRule
{
    if (!_customRecurrenceRule) {
        _customRecurrenceRule = [ECRecurrenceRule customRecurrenceRuleWithFrequency:EKRecurrenceFrequencyDaily interval:2];
    }
    
    return _customRecurrenceRule;
}

- (NSArray*)specificReccurenceRules
{
    if (!_specificReccurenceRules) {
        _specificReccurenceRules = [self createSpecificRecurrenceRules];
    }
    
    return _specificReccurenceRules;
}

- (NSArray*)createSpecificRecurrenceRules
{
    return @[[ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeNone],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly],
             [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly]];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSIndexPath* oldIndexPath = [self indexPathForECRecurrenceRule:self.ecRecurrenceRule];
    if (![oldIndexPath isEqual:indexPath]) {
        self.ecRecurrenceRule = [self ecRecurrenceRuleForIndexPath:indexPath];
        [self informDelegateThatRecurrenceRuleWasSelected];
        
        [tableView reloadData];
    }
}

- (NSIndexPath*)indexPathForECRecurrenceRule:(ECRecurrenceRule*)rule
{
    if (rule.type == ECRecurrenceRuleTypeCustom) {
        return [NSIndexPath indexPathForRow:0 inSection:kCustomRecurrenceRuleSection];
    } else {
        for (NSInteger i = 0; i < self.specificReccurenceRules.count; i++) {
            ECRecurrenceRule* specificRule = self.specificReccurenceRules[i];
            if (specificRule.type == rule.type) {
                return [NSIndexPath indexPathForRow:i inSection:kSpecificRecurrenceRuleSection];
            }
        }
    }
    
    // Code should not reach this point
    return nil;
}

- (ECRecurrenceRule*)ecRecurrenceRuleForIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == kCustomRecurrenceRuleSection) {
        return self.customRecurrenceRule;
    } else {
        return self.specificReccurenceRules[indexPath.row];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kSpecificRecurrenceRuleSection:
            return self.specificReccurenceRules.count;
            
        case kCustomRecurrenceRuleSection:
            return 1;
            
        default:
            return 0;
    }
}

static NSString* kSpecificRecurrenceRuleCellID =        @"specificRecurrenceRuleCell";
static NSString* kCustomRecurrenceRuleCellID =          @"customRecurrenceRuleCell";

const static NSInteger kSpecificRecurrenceRuleSection = 0;
const static NSInteger kCustomRecurrenceRuleSection =   1;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kSpecificRecurrenceRuleSection:
            return [self specificRecurrenceRuleCellForTableView:tableView indexPath:indexPath];
        case kCustomRecurrenceRuleSection:
            return [self customRecurrenceRuleCellForTableView:tableView indexPath:indexPath];
        default:
            return nil;
    }
}

- (UITableViewCell*)specificRecurrenceRuleCellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kSpecificRecurrenceRuleCellID];
    
    ECRecurrenceRule* rule = self.specificReccurenceRules[indexPath.row];
    cell.textLabel.text = rule.localizedName;
    
    if (rule.type == self.ecRecurrenceRule.type) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (ECEventCustomRecurrenceRuleCell*)customRecurrenceRuleCellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    ECEventCustomRecurrenceRuleCell* cell = [tableView dequeueReusableCellWithIdentifier:kCustomRecurrenceRuleCellID];
    
    cell.ruleLabel.text = self.customRecurrenceRule.localizedName;
    
    cell.checkmarkHidden = (self.ecRecurrenceRule.type != ECRecurrenceRuleTypeCustom);
    
    return cell;
}


#pragma mark - Recurrence Rule delegate

- (void)informDelegateThatRecurrenceRuleWasSelected
{
    if ([self.recurrenceRuleDelegate respondsToSelector:@selector(viewController:didSelectRecurrenceRule:)]) {
        [self.recurrenceRuleDelegate viewController:self didSelectRecurrenceRule:self.recurrenceRule];
    }
}

@end
