//
//  ECDualViewSwitcher.m
//  EvCal
//
//  Created by Tom on 8/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDualViewSwitcher.h"

@implementation ECDualViewSwitcher

#pragma mark - Lifecycle and Properties

- (instancetype)initWithFrame:(CGRect)frame primaryView:(nonnull UIView *)primaryView secondaryView:(nonnull UIView *)secondaryView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.primaryView = primaryView;
        self.secondaryView = secondaryView;
        self.visibleView = primaryView;
    }
    
    return self;
}

- (void)setPrimaryView:(UIView *)primaryView
{
    _primaryView = primaryView;
    
    [self addSubview:primaryView];
}

- (void)setSecondaryView:(UIView *)secondaryView
{
    _secondaryView = secondaryView;
    
    [self addSubview:secondaryView];
}


- (void)switchView:(BOOL)animated
{
    if (self.visibleView == self.primaryView) {
        [self switchToSecondayView:animated];
    } else {
        [self switchToPrimaryView:animated];
    }
}

- (void)switchToPrimaryView:(BOOL)animated
{
    if (self.visibleView != self.primaryView) {
        DDLogDebug(@"Switching to primary view");
    }
}

- (void)switchToSecondayView:(BOOL)animated
{
    if (self.visibleView != self.secondaryView) {
        DDLogDebug(@"Switching to secondary view");
    }
}

@end
