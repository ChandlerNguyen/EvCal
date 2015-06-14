//
//  ECEventView.m
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Modules
@import EventKit;
@import QuartzCore;

// Helpers
#import "NSDate+CupertinoYankee.h"

// EvCal Classes
#import "ECEventView.h"
#import "UIView+ECAdditions.h"
#import "UIColor+ECAdditions.h"


@interface ECEventView()

@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* locationLabel;

@end

@implementation ECEventView

#pragma mark - Lifecycle and Properties

- (instancetype)initWithEvent:(EKEvent*)event
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setEvent:event animated:NO];
        self.opaque = NO;
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0;
    }
    
    return self;
}

#define EVENT_VIEW_ALPHA    0.55

- (void)setEvent:(EKEvent *)event animated:(BOOL)animated
{
    _event = event;
    
    self.backgroundColor = [[UIColor colorWithCGColor:event.calendar.CGColor] colorWithAlphaComponent:EVENT_VIEW_ALPHA];
    [self updateLabelsWithEvent:event];
    [self setNeedsLayout];
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [self addLabel];
        _titleLabel.font = [UIFont boldSystemFontOfSize:13];
        _titleLabel.textColor = [UIColor textColorForCGColor:self.event.calendar.CGColor];
    }
    
    return _titleLabel;
}

- (UILabel*)locationLabel
{
    if (!_locationLabel && self.event.location) {
        _locationLabel = [self addLabel];
        _locationLabel.font = [UIFont systemFontOfSize:12];
        _locationLabel.textColor = [UIColor textColorForCGColor:self.event.calendar.CGColor];
    }
    
    return _locationLabel;
}


#pragma mark - Comparing Event Views

- (NSComparisonResult)compare:(ECEventView *)other
{
    NSComparisonResult result = [self.event compareStartDateWithEvent:other.event];
    if (result == NSOrderedSame) {
        return [self.event.endDate compare:other.event.endDate];
    } else {
        return result;
    }
}


#pragma mark - Event Labels

- (void)updateLabelsWithEvent:(EKEvent*)event
{
    self.titleLabel.text = event.title;
    self.locationLabel.text = event.location;
}


#pragma mark - Layout

#define LABEL_PADDING   8.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutLabels];
}

- (void)layoutLabels
{
    CGRect titleLabelFrame = CGRectMake(self.bounds.origin.x + LABEL_PADDING,
                                        self.bounds.origin.y + LABEL_PADDING,
                                        self.bounds.size.width,
                                        (self.bounds.size.height - 3 * LABEL_PADDING) / 2);
    
    DDLogDebug(@"Title Label Frame: %@", NSStringFromCGRect(titleLabelFrame));
    self.titleLabel.frame = titleLabelFrame;
    
    CGRect locationLabelFrame = CGRectMake(titleLabelFrame.origin.x,
                                           CGRectGetMaxY(titleLabelFrame) + LABEL_PADDING,
                                           titleLabelFrame.size.width,
                                           titleLabelFrame.size.height);
    
    DDLogDebug(@"Location Label Frame: %@", NSStringFromCGRect(locationLabelFrame));
    self.locationLabel.frame = locationLabelFrame;
}

@end
