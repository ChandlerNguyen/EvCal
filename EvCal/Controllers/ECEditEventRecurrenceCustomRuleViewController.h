//
//  ECEditEventRecurrenceCustomRuleViewController.h
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECRecurrenceRule;
@class ECEditEventRecurrenceCustomRuleViewController;

//------------------------------------------------------------------------------
// @name ECEditEventRecurrenceCustomRuleDelegate
//------------------------------------------------------------------------------

@protocol ECEditEventRecurrenceCustomRuleDelegate <NSObject>

/**
 *  Informs the receiver that the controller's custom recurrene rule was 
 *  selected.
 *
 *  @param vc   The controller sending the message.
 *  @param rule The selected rule.
 */
- (void)viewController:(ECEditEventRecurrenceCustomRuleViewController*)vc didSelectCustomRule:(ECRecurrenceRule*)rule;

@end

@interface ECEditEventRecurrenceCustomRuleViewController : UITableViewController

// The view controller's reecurrence rule.
@property (nonatomic, strong) ECRecurrenceRule* recurrenceRule;

// The view controller's delegate
@property (nonatomic, weak) id<ECEditEventRecurrenceCustomRuleDelegate> customRuleDelegate;

@end
