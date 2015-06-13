//
//  ECHourLine.m
//  EvCal
//
//  Created by Tom on 5/28/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECHourLine.h"
@interface ECHourLine()

@property (nonatomic, weak) UILabel* hourLabel;

@end

@implementation ECHourLine

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.date = date;
        self.hourLineInset = 66.0f;
    }
    
    return self;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    [self updateHourLabel:date];
}

- (void)setHourLineInset:(CGFloat)hourLineInset
{
    _hourLineInset = hourLineInset;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (UILabel*)hourLabel
{
    if (!_hourLabel) {
        UILabel* hourLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        hourLabel.textAlignment = NSTextAlignmentRight;
        hourLabel.font = [UIFont systemFontOfSize:11.0f];
        hourLabel.textColor = self.color;
        
        _hourLabel = hourLabel;
        
        [self addSubview:_hourLabel];
    }
    
    return _hourLabel;
}


@synthesize color = _color;

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    self.hourLabel.textColor = color;
    
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

- (void)updateHourLabel:(NSDate*)date
{    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    
    self.hourLabel.text = [formatter stringFromDate:date];
}

#pragma mark - Layout

#define HOUR_LABEL_HEIGHT       22.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutHourLabel];
}

- (void)layoutHourLabel
{
    CGRect hourLabelFrame = CGRectMake(self.bounds.origin.x,
                                       self.bounds.origin.y,
                                       self.hourLineInset,
                                       self.bounds.size.height);
    
    DDLogDebug(@"Hour Label Frame: %@", NSStringFromCGRect(hourLabelFrame));
    self.hourLabel.frame = hourLabelFrame;
}


#pragma mark - Drawing
#define HOUR_LINE_LEFT_PADDING  6.0f

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self eraseLine];
    [self drawHourLine];
}

- (void)eraseLine
{
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
}

- (void)drawHourLine
{
    [self.color setStroke];
    
    CGPoint lineOrigin = CGPointMake(CGRectGetMaxX(self.hourLabel.frame) + HOUR_LINE_LEFT_PADDING, CGRectGetMidY(self.hourLabel.frame));
    CGPoint lineTerminal = CGPointMake(CGRectGetMaxX(self.bounds), lineOrigin.y);
    
    UIBezierPath* linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:lineOrigin];
    [linePath addLineToPoint:lineTerminal];
    
    linePath.lineWidth = 1.0f;
    [linePath stroke];
}



@end
