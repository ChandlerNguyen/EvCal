//
//  ECTimeLine.m
//  EvCal
//
//  Created by Tom on 5/28/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECTimeLine.h"
@interface ECTimeLine()

@property (nonatomic, weak) UILabel* timeLabel;

@end

@implementation ECTimeLine

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.date = date;
        self.timeLineInset = 66.0f;
    }
    
    return self;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    [self updateTimeLabel:date];
}

- (void)setTimeLineInset:(CGFloat)timeLineInset
{
    _timeLineInset = timeLineInset;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (UILabel*)timeLabel
{
    if (!_timeLabel) {
        UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:11.0f];
        timeLabel.textColor = self.color;
        
        _timeLabel = timeLabel;
        
        [self addSubview:_timeLabel];
    }
    
    return _timeLabel;
}


@synthesize color = _color;

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    self.timeLabel.textColor = color;
    
    [self setNeedsDisplay];
}

- (UIColor*)color
{
    if (!_color) {
        _color = [UIColor lightGrayColor];
    }
    
    return _color;
}

#pragma mark - Updating Views

- (void)updateTimeLabel:(NSDate*)date
{    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    
    self.timeLabel.text = [formatter stringFromDate:date];
}

#pragma mark - Layout

#define HOUR_LABEL_HEIGHT       22.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutTimeLabel];
}

- (void)layoutTimeLabel
{
    CGRect timeLabelFrame = CGRectMake(self.bounds.origin.x,
                                       self.bounds.origin.y,
                                       self.timeLineInset,
                                       self.bounds.size.height);
    
    DDLogDebug(@"Time Label Frame: %@", NSStringFromCGRect(timeLabelFrame));
    self.timeLabel.frame = timeLabelFrame;
}


#pragma mark - Drawing
#define HOUR_LINE_LEFT_PADDING  6.0f

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self eraseLine];
    [self drawTimeLine];
}

- (void)eraseLine
{
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
}

- (void)drawTimeLine
{
    [self.color setStroke];
    
    CGPoint lineOrigin = CGPointMake(CGRectGetMaxX(self.timeLabel.frame) + HOUR_LINE_LEFT_PADDING, CGRectGetMidY(self.timeLabel.frame));
    CGPoint lineTerminal = CGPointMake(CGRectGetMaxX(self.bounds), lineOrigin.y);
    
    UIBezierPath* linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:lineOrigin];
    [linePath addLineToPoint:lineTerminal];
    
    linePath.lineWidth = 1.0f;
    [linePath stroke];
}



@end
