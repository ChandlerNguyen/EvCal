//
//  ECEventView.m
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Modules
@import EventKit;

// EvCal Classes
#import "ECEventView.h"
#import "UIView+ECAdditions.h"


@interface ECEventView()

@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* locationLabel;

@end

@implementation ECEventView

#pragma mark - Lifecycle and Properties

- (instancetype)initWithEvent:(EKEvent*)event
{
    self = [super initWithFrame:CGRectZero];
    if (!self) {
        // set event without updating layout
        _event = event;
        [self updateLabelsWithEvent:event];
    }
    
    return self;
}

- (void)setEvent:(EKEvent *)event animated:(BOOL)animated
{
    _event = event;
    
    [self updateLabelsWithEvent:event];
    [self setNeedsLayout];
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [self addLabel];
    }
    
    return _titleLabel;
}

- (UILabel*)locationLabel
{
    if (!_locationLabel) {
        _locationLabel = [self addLabel];
    }
    
    return _locationLabel;
}


#pragma mark - Event Labels

- (void)updateLabelsWithEvent:(EKEvent*)event
{
    self.titleLabel.text = event.title;
    self.locationLabel.text = event.location;
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutLabels];
}

- (void)layoutLabels
{
    // pass
}

@end
