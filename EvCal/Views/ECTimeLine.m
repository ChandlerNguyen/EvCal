//
//  ECTimeLine.m
//  EvCal
//
//  Created by Tom on 5/28/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECTimeLine.h"
@interface ECTimeLine()

@property (nonatomic, readwrite) CGFloat timeLineInset;
@property (nonatomic, weak) UILabel* timeLabel;

@end

@implementation ECTimeLine

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.date = date;
        
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.timeLineInset = [self calculateTimeLineInset];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    [self updateTimeLabel:date];
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

- (NSString*)dateFormatTemplate
{
    if (!_dateFormatTemplate) {
        _dateFormatTemplate = @"j";
    }
    
    return _dateFormatTemplate;
}

- (BOOL)timeHidden
{
    return self.timeLabel.hidden;
}

- (void)setTimeHidden:(BOOL)timeHidden
{
    self.timeLabel.hidden = timeHidden;
}

#pragma mark - Updating Views

- (void)updateTimeLabel:(NSDate*)date
{    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:self.dateFormatTemplate options:0 locale:[NSLocale currentLocale]];
    
    self.timeLabel.text = [formatter stringFromDate:date];
}

#pragma mark - Layout

#define HOUR_LABEL_HEIGHT       22.0f
#define HOUR_LINE_LEFT_PADDING  6.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutTimeLabel];
}

- (void)layoutTimeLabel
{
    CGRect timeLabelFrame = CGRectMake(self.bounds.origin.x,
                                       self.bounds.origin.y,
                                       self.timeLineInset - HOUR_LINE_LEFT_PADDING,
                                       self.bounds.size.height);
    
    self.timeLabel.frame = timeLabelFrame;
}

- (CGFloat)calculateTimeLineInset
{
    NSString* maximumWidthTimeString = NSLocalizedString(@"12:59 PM", @"The longest possible time string in terms of total character width");
    CGRect maximumTimeLabelFrame = [maximumWidthTimeString boundingRectWithSize:CGSizeMake(1000, 1000)
                                                                        options:0
                                                                     attributes:@{NSFontAttributeName : self.timeLabel.font}
                                                                        context:nil];
    return ceilf(maximumTimeLabelFrame.size.width) + HOUR_LINE_LEFT_PADDING;
}


#pragma mark - Drawing

#define TIME_LINE_STROKE_WIDTH  0.5f

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self eraseLine];
    [self drawTimeLine];
}

- (void)eraseLine
{
    [[UIColor clearColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
}

- (void)drawTimeLine
{
    [self.color setStroke];
    
    CGPoint lineOrigin = CGPointMake(self.timeLineInset, CGRectGetMidY(self.timeLabel.frame));
    CGPoint lineTerminal = CGPointMake(CGRectGetMaxX(self.bounds), lineOrigin.y);
    
    UIBezierPath* linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:lineOrigin];
    [linePath addLineToPoint:lineTerminal];
    
    linePath.lineWidth = TIME_LINE_STROKE_WIDTH;
    [linePath stroke];
}



@end
