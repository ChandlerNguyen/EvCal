//
//  ECEditEventRecurrenceRuleCell.h
//  EvCal
//
//  Created by Tom on 8/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECRecurrenceRule;

@interface ECEditEventRecurrenceRuleCell : UITableViewCell

@property (nonatomic, strong) ECRecurrenceRule* recurrenceRule;

@end
