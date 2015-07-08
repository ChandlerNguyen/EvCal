//
//  ECEventCustomRecurrenceRuleCell.h
//  EvCal
//
//  Created by Tom on 7/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECEventCustomRecurrenceRuleCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* ruleLabel;

@property (nonatomic) BOOL checkmarkHidden;

@end
