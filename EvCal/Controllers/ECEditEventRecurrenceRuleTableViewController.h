//
//  ECEditEventRecurrenceRuleTableViewController.h
//  EvCal
//
//  Created by Tom on 7/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EKRecurrenceRule;
@class ECEditEventRecurrenceRuleTableViewController;
@protocol ECEditEventRecurrenceRuleViewControllerDelegate <NSObject>

@optional
- (void)viewController:(ECEditEventRecurrenceRuleTableViewController*)vc didSelectRecurrenceRule:(EKRecurrenceRule*)rule;

@end

@interface ECEditEventRecurrenceRuleTableViewController : UITableViewController

@property (nonatomic, weak) id<ECEditEventRecurrenceRuleViewControllerDelegate> recurrenceRuleDelegate;
@property (nonatomic, strong) EKRecurrenceRule* recurrenceRule;

@end
