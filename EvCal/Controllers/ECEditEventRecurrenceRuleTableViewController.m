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
    return 0;
}

static NSString* recurrenceRuleCellID =         @"recurrenceRuleCell";

static NSInteger customRecurrenceRuleSection =  1;
static NSInteger recurrenceRuleTypeCount =      6;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recurrenceRuleCellID forIndexPath:indexPath];
    
    //ECRecurrenceRule* cellRule = [self recurrenceRuleForIndexPath:indexPath];
    cell.textLabel.text = @"test";//cellRule.localizedName;
    
    return cell;
}



@end
