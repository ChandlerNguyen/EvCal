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
        self.hourLineInset = 80.0f;
    }
    
    return self;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    [self updateHourLabel:date];
}

- (UILabel*)hourLabel
{
    if (!_hourLabel) {
        UILabel* hourLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        hourLabel.textAlignment = NSTextAlignmentRight;
        
        _hourLabel = hourLabel;
        
        [self addSubview:_hourLabel];
    }
    
    return _hourLabel;
}

- (void)updateHourLabel:(NSDate*)date
{    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j:mm" options:0 locale:[NSLocale currentLocale]];
    
    self.hourLabel.text = [formatter stringFromDate:date];
}

#pragma mark - Layout

#define HOUR_LABEL_WIDTH        60.0f
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
#define HOUR_LINE_LEFT_PADDING  8.0f
#define HOUR_LINE_DOT_RADIUS    2.0f

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
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] setStroke];
    
    CGPoint dotCenter = CGPointMake(CGRectGetMaxX(self.hourLabel.frame) + HOUR_LINE_LEFT_PADDING, CGRectGetMidY(self.hourLabel.frame));
    CGRect dotRect = CGRectMake(dotCenter.x - HOUR_LINE_DOT_RADIUS,
                                dotCenter.y - HOUR_LINE_DOT_RADIUS,
                                2 * HOUR_LINE_DOT_RADIUS,
                                2 * HOUR_LINE_DOT_RADIUS);
    
    [[UIBezierPath bezierPathWithOvalInRect:dotRect] fill];
    
    CGPoint lineTerminal = CGPointMake(CGRectGetMaxX(self.bounds), dotCenter.y);
    
    UIBezierPath* linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:dotCenter];
    [linePath addLineToPoint:lineTerminal];
    
    [linePath stroke];
}



@end
