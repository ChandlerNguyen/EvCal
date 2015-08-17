//
//  ECDualViewSwitcher.m
//  EvCal
//
//  Created by Tom on 8/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDualViewSwitcher.h"

@interface ECDualViewSwitcher()

@property (nonatomic) BOOL primaryViewNeedsLayout;
@property (nonatomic) BOOL secondaryViewNeedsLayout;

@property (nonatomic, weak, readwrite) UIView* visibleView;

@end

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

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(self.frame, frame)) {
        self.primaryViewNeedsLayout = YES;
        self.secondaryViewNeedsLayout = YES;
    }
    
    [super setFrame:frame];
}

- (void)setPrimaryView:(UIView *)primaryView
{
    _primaryView = primaryView;
    
    self.primaryViewNeedsLayout = YES;
    [self addSubview:primaryView];
}

- (void)setSecondaryView:(UIView *)secondaryView
{
    _secondaryView = secondaryView;
    
    self.secondaryViewNeedsLayout = YES;
    [self addSubview:secondaryView];
}

- (UIView*)visibleView
{
    if (!_visibleView) {
        _visibleView = self.primaryView;
    }
    
    return _visibleView;
}


#pragma mark - Layout

const static NSTimeInterval kSwitchViewsAnimationDuration = 0.2f;

- (void)layoutSubviews
{
    [super layoutSubviews];
   
    if (self.primaryViewNeedsLayout) {
        [self layoutPrimaryView];
    }
    
    if (self.secondaryViewNeedsLayout) {
        [self layoutSecondaryView];
    }
}

- (void)layoutPrimaryAndSecondaryView:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:kSwitchViewsAnimationDuration animations:^{
            [self layoutPrimaryView];
            [self layoutSecondaryView];
        }];
    } else {
        [self layoutPrimaryView];
        [self layoutSecondaryView];
    }
}

- (void)layoutPrimaryView
{
    CGFloat horizontalOffset = (self.visibleView == self.primaryView) ? 0 : -self.bounds.size.width;
    [self layoutView:self.primaryView withHorizontalOffset:horizontalOffset];
    
    self.primaryViewNeedsLayout = NO;
}

- (void)layoutSecondaryView
{
    CGFloat horizontalOffset = (self.visibleView == self.secondaryView) ? 0 : self.bounds.size.width;
    [self layoutView:self.secondaryView withHorizontalOffset:horizontalOffset];
    
    self.secondaryViewNeedsLayout = NO;
}

- (void)layoutView:(UIView*)view withHorizontalOffset:(CGFloat)horizontalOffset
{
    CGRect viewFrame = CGRectMake(self.bounds.origin.x + horizontalOffset,
                                           self.bounds.origin.y,
                                           self.bounds.size.width,
                                           self.bounds.size.height);
    
    view.frame = viewFrame;
}

#pragma mark - Switching Views

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
        self.visibleView = self.primaryView;
        
        [self layoutPrimaryAndSecondaryView:animated];
    }
}

- (void)switchToSecondayView:(BOOL)animated
{
    if (self.visibleView != self.secondaryView) {
        self.visibleView = self.secondaryView;
        
        [self layoutPrimaryAndSecondaryView:animated];
    }
}

@end
