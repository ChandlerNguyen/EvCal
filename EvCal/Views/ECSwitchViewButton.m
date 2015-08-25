//
//  ECSwitchViewButton.m
//  EvCal
//
//  Created by Tom on 8/25/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECSwitchViewButton.h"

@implementation ECSwitchViewButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _direction = ECSwitchViewButtonDirectionRight;
    }
    
    return self;
}

- (void)setDirection:(ECSwitchViewButtonDirection)direction
{
    _direction = direction;
    [self setNeedsLayout];
}

#pragma mark - Layout

const static NSInteger kAccessoryViewWidth = 32.0f;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutAccessoryView];
    [self layoutButton];
}

- (void)layoutAccessoryView
{
    CGFloat accessoryViewOriginX;
    switch (self.direction) {
        case ECSwitchViewButtonDirectionRight:
            accessoryViewOriginX = CGRectGetMaxX(self.bounds) - kAccessoryViewWidth;
            break;
            
        case ECSwitchViewButtonDirectionLeft:
            accessoryViewOriginX = self.bounds.origin.x;
            break;
    }
    
    CGRect accessoryViewFrame = CGRectMake(accessoryViewOriginX,
                                           self.bounds.origin.y,
                                           kAccessoryViewWidth,
                                           self.bounds.size.height);
    self.accessoryView.frame = accessoryViewFrame;
}

- (void)layoutButton
{
    CGFloat buttonFrameOriginX;
    switch (self.direction) {
        case ECSwitchViewButtonDirectionRight:
            buttonFrameOriginX = self.bounds.origin.x;
            break;
            
        case ECSwitchViewButtonDirectionLeft:
            buttonFrameOriginX = self.bounds.origin.x + kAccessoryViewWidth;
            break;
    }
    
    CGRect buttonFrame = CGRectMake(buttonFrameOriginX,
                                    self.bounds.origin.y,
                                    self.bounds.size.width - kAccessoryViewWidth,
                                    self.bounds.size.height);
    
    self.button.frame = buttonFrame;
}

@end
