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

@property (nonatomic, strong) NSArray* specificReccurenceRules;
@property (nonatomic, strong) ECRecurrenceRule* customRecurrenceRule;

@end

@implementation ECEditEventRecurrenceRuleTableViewController

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

const static NSInteger kNoneRecurrenceRuleRow =         0;
const static NSInteger kDailyRecurrenceRuleRow =        1;
const static NSInteger kWeekdaysRecurrenceRuleRow =     2;
const static NSInteger kWeeklyRecurrenceRuleRow =       3;
const static NSInteger kMonthlyRecurrenceRuleRow =      4;
const static NSInteger kYearlyRecurrenceRuleRow =       5;

static NSInteger kSpecificRuleTypeCount =               6;

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
    
    if (rule.type == self.recurrenceRule.type) {
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
    
    if (self.recurrenceRule.type == ECRecurrenceRuleTypeCustom) {
        cell.checkmarkView.backgroundColor = [UIColor purpleColor];
    } else {
        cell.checkmarkView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

@end
