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

typedef NS_ENUM(NSInteger, ECEventViewLayoutType) {
    ECEventViewLayoutTypeFixedVerticalOffset,
    ECEventViewLayoutTypeVerticallyCentered,
    ECEventViewLayoutTypeHorizontal,
};

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
        self.event = event;
        self.opaque = YES;
        self.layer.cornerRadius = 5.0;
        self.layer.borderWidth = 0.5;
    }
    
    return self;
}

#define EVENT_VIEW_ALPHA    0.55

- (void)setEvent:(EKEvent *)event
{
    _event = event;
    
    self.backgroundColor = [UIColor eventViewBackgroundColorForCGColor:event.calendar.CGColor];
    self.layer.borderColor = event.calendar.CGColor;
    [self updateLabelsWithEvent:event];
    [self setNeedsLayout];
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [self addLabel];
        _titleLabel.font = [self titleLabelFont];
    }
    
    return _titleLabel;
}

- (UILabel*)locationLabel
{
    if (!_locationLabel && self.event.location) {
        _locationLabel = [self addLabel];
        _locationLabel.font = [self locationLabelFont];
    }
    
    return _locationLabel;
}

- (UIFont*)titleLabelFont
{
    return [UIFont boldSystemFontOfSize:[self fontSizeForDuration:[self eventDuration:self.event]]];
}

- (UIFont*)locationLabelFont
{
    return [UIFont systemFontOfSize:[self fontSizeForDuration:[self eventDuration:self.event]]];
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
    
    self.titleLabel.textColor = [UIColor textColorForCGColor:self.event.calendar.CGColor];
    self.locationLabel.textColor = [UIColor textColorForCGColor:self.event.calendar.CGColor];
    
    self.titleLabel.font = [self titleLabelFont];
    self.locationLabel.font = [self locationLabelFont];
}


#pragma mark - Layout

#define LABEL_OUTER_PADDING         6.0f
#define LABEL_HORIZONTAL_PADDING    2.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutLabels];
}

CG_INLINE CGSize ceilCGSize(CGSize size)
{
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

- (void)layoutLabels
{
    CGSize titleSize =  ceilCGSize([self.titleLabel.text boundingRectWithSize:self.bounds.size
                                                           options:0
                                                        attributes:@{NSFontAttributeName : self.titleLabel.font}
                                                           context:nil].size);
    
    CGSize locationSize = ceilCGSize([self.locationLabel.text boundingRectWithSize:self.bounds.size
                                                                           options:0
                                                                        attributes:@{NSFontAttributeName : [self locationLabelFont]}
                                                                           context:nil].size);
    
    ECEventViewLayoutType layoutType = [self eventViewLayoutTypeForTitleSize:titleSize locationSize:locationSize];
    switch (layoutType) {
        case ECEventViewLayoutTypeFixedVerticalOffset:
            [self layoutLabelsVerticallyWithTitleSize:titleSize locationSize:locationSize];
            break;
            
        case ECEventViewLayoutTypeVerticallyCentered:
            [self layoutLabelsVerticallyCenteredWithTitleSize:titleSize locationSize:locationSize];
            break;
            
        case ECEventViewLayoutTypeHorizontal:
            [self layoutLabelsHorizontallyWithTitleSize:titleSize locationSize:locationSize];
            break;
    }
}

- (ECEventViewLayoutType)eventViewLayoutTypeForTitleSize:(CGSize)titleSize locationSize:(CGSize)locationSize
{
    CGFloat totalLabelHeight = titleSize.height + locationSize.height;
    if (totalLabelHeight + 2 * LABEL_OUTER_PADDING < self.bounds.size.height) {
        return ECEventViewLayoutTypeFixedVerticalOffset;
    } else if (totalLabelHeight + LABEL_OUTER_PADDING <= self.bounds.size.height) {
        return ECEventViewLayoutTypeVerticallyCentered;
    } else {
        return ECEventViewLayoutTypeHorizontal;
    }
}

- (void)layoutLabelsVerticallyWithTitleSize:(CGSize)titleSize locationSize:(CGSize)locationSize
{
    CGRect titleLabelFrame = CGRectMake(self.bounds.origin.x + LABEL_OUTER_PADDING,
                                        self.bounds.origin.y + LABEL_OUTER_PADDING,
                                        titleSize.width,
                                        titleSize.height);
    
    self.titleLabel.frame = titleLabelFrame;
    
    CGRect locationLabelFrame = CGRectMake(self.bounds.origin.x + LABEL_OUTER_PADDING,
                                           CGRectGetMaxY(titleLabelFrame),
                                           locationSize.width,
                                           locationSize.height);
    
    self.locationLabel.frame = locationLabelFrame;
}

- (void)layoutLabelsVerticallyCenteredWithTitleSize:(CGSize)titleSize locationSize:(CGSize)locationSize
{
    CGFloat verticallyCenteredOffset = floorf((self.bounds.size.height - titleSize.height - locationSize.height) / 2.0f);
    CGRect titleLabelFrame = CGRectMake(self.bounds.origin.x + LABEL_OUTER_PADDING,
                                        self.bounds.origin.y + verticallyCenteredOffset,
                                        titleSize.width,
                                        titleSize.height);
    
    CGRect locationLabelFrame = CGRectMake(self.bounds.origin.x + LABEL_OUTER_PADDING,
                                 CGRectGetMaxY(titleLabelFrame),
                                 locationSize.width,
                                 locationSize.height);
    
    self.titleLabel.frame = titleLabelFrame;
    self.locationLabel.frame = locationLabelFrame;
}

- (void)layoutLabelsHorizontallyWithTitleSize:(CGSize)titleSize locationSize:(CGSize)locationSize
{
    CGRect titleLabelFrame = CGRectMake(self.bounds.origin.x + LABEL_OUTER_PADDING,
                                        self.bounds.origin.y + (self.bounds.size.height - titleSize.height) / 2.0f,
                                        titleSize.width,
                                        titleSize.height);
    
    self.titleLabel.frame = titleLabelFrame;
    
    CGFloat locationLabelOriginX = CGRectGetMaxX(titleLabelFrame) + LABEL_HORIZONTAL_PADDING;
    locationSize.width = MAX(MIN(locationSize.width, self.bounds.size.width - locationLabelOriginX), 0);
    CGRect locationLabelFrame = CGRectMake(locationLabelOriginX,
                                           titleLabelFrame.origin.y,
                                           locationSize.width,
                                           locationSize.height);
    
    self.locationLabel.frame = locationLabelFrame;
}

#define FORTY_MINUTES   60 * 40
#define THIRTY_MINUTES  60 * 30
#define FIFTEEN_MINUTES 60 * 15

- (CGFloat)fontSizeForDuration:(NSTimeInterval)duration
{
    if (duration > FORTY_MINUTES) {
        return 12.0f;
    } else if (duration > THIRTY_MINUTES) {
        return 10.0f;
    } else if (duration > FIFTEEN_MINUTES) {
        return 9.0f;
    } else {
        return 8.0f;
    }
}

- (NSTimeInterval)eventDuration:(EKEvent*)event
{
    return [event.endDate timeIntervalSinceDate:event.startDate];
}

@end
