//
//  ECEditEventRecurrenceRuleTableViewController.m
//  EvCal
//
//  Created by Tom on 7/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEditEventRecurrenceRuleTableViewController.h"
#import "ECRecurrenceRule.h"

@interface ECEditEventRecurrenceRuleTableViewController ()

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;

@end

@implementation ECEditEventRecurrenceRuleTableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kSpecificRecurrenceRuleSection:
            return kSpecificRuleTypeCount;
            
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
    
    ECRecurrenceRule* rule = [self recurrenceRuleForIndexPath:indexPath];
    cell.textLabel.text = rule.localizedName;
    
    if (rule.type == self.recurrenceRule.type) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (UITableViewCell*)customRecurrenceRuleCellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCustomRecurrenceRuleCellID];
    
    ECRecurrenceRule* rule = [self recurrenceRuleForIndexPath:indexPath];
    cell.textLabel.text = rule.localizedName;
    
    if (rule.type == self.recurrenceRule.type) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (ECRecurrenceRule*)recurrenceRuleForIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case kSpecificRecurrenceRuleSection:
            return [self specificRecurrenceRuleForIndexPath:indexPath];
            
        case kCustomRecurrenceRuleSection:
            if (self.recurrenceRule.type == ECRecurrenceRuleTypeCustom) {
                return self.recurrenceRule;
            } else {
                return [ECRecurrenceRule customRecurrenceRuleWithFrequency:EKRecurrenceFrequencyDaily interval:2];
            }
            
        default:
            return nil;
    }
}

- (ECRecurrenceRule*)specificRecurrenceRuleForIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
        case kNoneRecurrenceRuleRow:
            return [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeNone];
            
        case kDailyRecurrenceRuleRow:
            return [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeDaily];
            
        case kWeekdaysRecurrenceRuleRow:
            return [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekdays];
            
        case kWeeklyRecurrenceRuleRow:
            return [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeWeekly];
            
        case kMonthlyRecurrenceRuleRow:
            return [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeMonthly];
            
        case kYearlyRecurrenceRuleRow:
            return [ECRecurrenceRule recurrenceRuleForRecurrenceType:ECRecurrenceRuleTypeYearly];
            
        default:
            return nil;
    }
}

@end
