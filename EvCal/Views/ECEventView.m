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
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0;
    }
    
    return self;
}

- (void)setEvent:(EKEvent *)event animated:(BOOL)animated
{
    _event = event;
    
    self.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];
    [self updateLabelsWithEvent:event];
    [self setNeedsLayout];
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [self addLabel];
        _titleLabel.font = [UIFont systemFontOfSize:11];
    }
    
    return _titleLabel;
}

- (UILabel*)locationLabel
{
    if (!_locationLabel) {
        _locationLabel = [self addLabel];
        _locationLabel.font = [UIFont systemFontOfSize:11];
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
    CGRect titleLabelFrame = CGRectMake(self.bounds.origin.x + LABEL_PADDING, self.bounds.origin.y + LABEL_PADDING, self.bounds.size.width, (self.bounds.size.height - 3 * LABEL_PADDING) / 2);
    
    self.titleLabel.frame = titleLabelFrame;
    
    CGRect locationLabelFrame = CGRectMake(titleLabelFrame.origin.x, CGRectGetMaxY(titleLabelFrame) + LABEL_PADDING, titleLabelFrame.size.width, titleLabelFrame.size.height);
    
    self.locationLabel.frame = locationLabelFrame;
}


#pragma mark Height and Positioning

- (CGFloat)heightInRect:(CGRect)rect forDate:(NSDate *)date
{
    CGFloat height = 0;
    
    if (rect.size.height > 0) {
        NSArray* hours = [date hoursOfDay];
        float eventHoursInDay = [self eventHoursInDate:date];
        
        height = floorf(rect.size.height * (eventHoursInDay / hours.count));
    }
    
    return height;
}

- (float)eventHoursInDate:(NSDate*)date
{
    NSDate* beginningOfDay = [date beginningOfDay];
    NSDate* endOfDay = [date endOfDay];
    
    NSDate* start = nil;
    NSDate* end = nil;
    
    if ([self.event.startDate compare:beginningOfDay] == NSOrderedAscending) { // event starts before the given day
        start = beginningOfDay;
    } else {
        start = self.event.startDate;
    }
    
    if ([self.event.endDate compare:endOfDay] == NSOrderedDescending) { // event begins after the given day
        end = endOfDay;
    } else {
        end = self.event.endDate;
    }
    
    return (float)[end timeIntervalSinceDate:start] / 3600.0f;
}

- (NSDate*)closestDatePrecedingDate:(NSDate*)date inDates:(NSArray*)dates
{
    NSArray* sortedDates = [dates sortedArrayUsingSelector:@selector(compare:)];
    NSDate* previousDate = nil;
    for (NSDate* otherDate in sortedDates) {
        NSComparisonResult result = [date compare:otherDate];
        
        switch (result) {
            case NSOrderedSame:
                return otherDate;
                break;
                
            case NSOrderedAscending:
                break;
                
            case NSOrderedDescending:
                break;
                
            default:
                break;
        }
    }
    
    return previousDate;
}


@end
