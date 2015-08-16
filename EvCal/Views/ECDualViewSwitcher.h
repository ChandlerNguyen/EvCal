//
//  ECDualViewSwitcher.h
//  EvCal
//
//  Created by Tom on 8/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDualViewSwitcher : UIView

@property (nonatomic, weak) UIView* primaryView;
@property (nonatomic, weak) UIView* secondaryView;
@property (nonatomic, weak) UIView* visibleView;

- (void)switchView;
- (void)switchToPrimaryView;
- (void)switchToSecondayView;

@end
