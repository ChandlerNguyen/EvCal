//
//  ECEditEventRecurrenceRuleCell.h
//  EvCal
//
//  Created by Tom on 8/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class ECRecurrenceRule;
@class ECEditEventRecurrenceRuleCell;

/**
 *  The ECEditEventRecurrenceCellDelegate receives updates when the recurrence
 *  cell updates its recurrence rule.
 */

@protocol ECEditEventRecurrenceRuleCellDelegate <NSObject>

@optional
- (void)recurrenceCell:(ECEditEventRecurrenceRuleCell*)cell didSelectRecurrenceRule:(ECRecurrenceRule*)rule;

@end

#import <UIKit/UIKit.h>

@interface ECEditEventRecurrenceRuleCell : UITableViewCell

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The recurrence rule presented by the cell. Setting this value will cause the
// cell to update its UI accordingly.
@property (nonatomic, strong) ECRecurrenceRule* recurrenceRule;

// The delegate to receive updates concerning changes to the recurrence rule
// cell
@property (nonatomic, weak) id<ECEditEventRecurrenceRuleCellDelegate> recurrenceRuleDelegate;

@end
