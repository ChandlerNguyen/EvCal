//
//  ECEventCustomRecurrenceRuleCell.m
//  EvCal
//
//  Created by Tom on 7/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEventCustomRecurrenceRuleCell.h"
#import "MSCellAccessory.h"

@interface ECEventCustomRecurrenceRuleCell()

@property (nonatomic, weak) UIView* checkmarkView;
@property (nonatomic, weak) IBOutlet UIView* checkmarkViewContainer;

@end

@implementation ECEventCustomRecurrenceRuleCell

- (void)awakeFromNib {
    self.checkmarkViewContainer.backgroundColor = self.backgroundColor;
    self.checkmarkHidden = YES;
}

- (UIView*)checkmarkView
{
    if (!_checkmarkView) {
        UIView* checkmarkView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIApplication sharedApplication].delegate.window.tintColor];
        _checkmarkView = checkmarkView;
        [self.checkmarkViewContainer addSubview:_checkmarkView];
    }
    
    return _checkmarkView;
}

- (void)setCheckmarkHidden:(BOOL)checkmarkHidden
{
    self.checkmarkView.hidden = checkmarkHidden;
}

- (BOOL)checkmarkHidden
{
    return self.checkmarkView.hidden;
}


@end
