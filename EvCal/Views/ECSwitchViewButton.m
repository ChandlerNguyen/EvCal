//
//  ECSwitchViewButton.m
//  EvCal
//
//  Created by Tom on 8/25/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import QuartzCore;
#import "ECSwitchViewButton.h"
#import "UIColor+ECAdditions.h"
#import "MSCellAccessory.h"

@interface ECSwitchViewButton()

@property (nonatomic, weak) MSCellAccessory* disclosureView;

@end

@implementation ECSwitchViewButton

#pragma mark - Properties and Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _direction = ECSwitchViewButtonDirectionRight;
    [self updateAccessoryView];
    [self updateButton];
}

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
    [self updateAccessoryView];
    [self updateButton];
    [self setNeedsLayout];
}


#pragma mark - Accessory View

- (void)updateAccessoryView
{
    MSCellAccessory* disclosureView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor ecPurpleColor]];
    
    if (self.direction == ECSwitchViewButtonDirectionLeft) {
        disclosureView.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
    }
    
    [self.disclosureView removeFromSuperview];
    self.disclosureView = disclosureView;
    [self.accessoryView addSubview:disclosureView];
}

- (void)updateButton
{
    switch (self.direction) {
        case ECSwitchViewButtonDirectionRight:
            self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            break;
            
        case ECSwitchViewButtonDirectionLeft:
            self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            break;
    }
}


#pragma mark - Layout

const static CGFloat kAccessoryViewWidth = 32.0f;
const static CGFloat kAccessoryViewInset = 8.0f;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutAccessoryView];
//    [self layoutButton];
}

- (void)layoutAccessoryView
{
    CGFloat accessoryViewOriginX;
    switch (self.direction) {
        case ECSwitchViewButtonDirectionRight:
            accessoryViewOriginX = CGRectGetMaxX(self.bounds) - (kAccessoryViewWidth + kAccessoryViewInset);
            break;
            
        case ECSwitchViewButtonDirectionLeft:
            accessoryViewOriginX = self.bounds.origin.x + kAccessoryViewInset;
            break;
    }
    
    CGRect accessoryViewFrame = CGRectMake(accessoryViewOriginX,
                                           self.bounds.origin.y,
                                           kAccessoryViewWidth,
                                           self.bounds.size.height);
    self.accessoryView.frame = accessoryViewFrame;
}

//- (void)layoutButton
//{
//    CGFloat buttonFrameOriginX;
//    switch (self.direction) {
//        case ECSwitchViewButtonDirectionRight:
//            buttonFrameOriginX = self.bounds.origin.x;
//            break;
//            
//        case ECSwitchViewButtonDirectionLeft:
//            buttonFrameOriginX = self.bounds.origin.x + kAccessoryViewWidth;
//            break;
//    }
//    CGRect buttonFrame = CGRectMake(buttonFrameOriginX,
//                                    self.bounds.origin.y,
//                                    self.bounds.size.width - kAccessoryViewWidth,
//                                    self.bounds.size.height);
//    
//    self.button.frame = buttonFrame;
//}
//#define FLAT_DISCLOSURE_START_X                             CGRectGetMaxX(self.bounds)-1.5
//#define FLAT_DISCLOSURE_START_Y                             CGRectGetMidY(self.bounds)+0.25
//#define FLAT_DISCLOSURE_RADIUS                              4.8
//#define FLAT_DISCLOSURE_WIDTH                               2.2
//#define FLAT_DISCLOSURE_SHADOW_OFFSET                       CGSizeMake(.0, -1.0)
//#define FLAT_DISCLOSURE_POSITON                             CGPointMake(18.0, 13.5)
//
//CGContextRef ctx = UIGraphicsGetCurrentContext();
//CGContextMoveToPoint(ctx, FLAT_DISCLOSURE_START_X-FLAT_DISCLOSURE_RADIUS, FLAT_DISCLOSURE_START_Y-FLAT_DISCLOSURE_RADIUS);
//CGContextAddLineToPoint(ctx, FLAT_DISCLOSURE_START_X, FLAT_DISCLOSURE_START_Y);
//CGContextAddLineToPoint(ctx, FLAT_DISCLOSURE_START_X-FLAT_DISCLOSURE_RADIUS, FLAT_DISCLOSURE_START_Y+FLAT_DISCLOSURE_RADIUS);
//CGContextSetLineCap(ctx, kCGLineCapSquare);
//CGContextSetLineJoin(ctx, kCGLineJoinMiter);
//CGContextSetLineWidth(ctx, FLAT_DISCLOSURE_WIDTH);
//
//if (self.highlighted)
//{
//    [self.highlightedColor setStroke];
//}
//else
//{
//    [self.accessoryColor setStroke];
//}
//
//CGContextStrokePath(ctx);

@end
