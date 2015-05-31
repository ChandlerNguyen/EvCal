//
//  ECWeekdayPicker.m
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "UIView+ECAdditions.h"
#import "ECWeekdayPicker.h"
#import "ECDateView.h"
#import "ECDateViewFactory.h"


#define DATE_PICKER_CELL_REUSE_ID   @"DatePickerCell"

@interface ECWeekdayPicker()

@property (nonatomic, strong) NSDateFormatter* dateFormatter;

// views
@property (nonatomic, strong) NSArray* weekdayLabels;
@property (nonatomic, weak) UIScrollView* weekdaysScrollView;

@property (nonatomic, weak) ECDateView* selectedDateView;
@property (nonatomic, strong) NSArray* leftDateViews;
@property (nonatomic, strong) NSArray* currentDateViews;
@property (nonatomic, strong) NSArray* rightDateViews;

// weekday arrays
@property (nonatomic, strong, readwrite) NSArray* weekdays;
@property (nonatomic, strong) NSArray* prevWeekdays;
@property (nonatomic, strong) NSArray* nextWeekdays;

@end

@implementation ECWeekdayPicker

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(NSDate *)date
{
    DDLogDebug(@"Initializing weekday picker with date %@", date);
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setSelectedDate:date animated:YES];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (NSDateFormatter*)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        _dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd" options:0 locale:[NSLocale currentLocale]];
    }
    
    return _dateFormatter;
}

- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated
{
    DDLogDebug(@"Changing weekday picker selected date to %@", selectedDate);
    _selectedDate = selectedDate;
    [self updateWeekdaysWithDate:selectedDate];
    
    [self.pickerDelegate weekdayPicker:self didSelectDate:selectedDate];
}

- (UIScrollView *)weekdaysScrollView
{
    if (!_weekdaysScrollView) {
        UIScrollView* weekdaysScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        
        weekdaysScrollView.pagingEnabled = YES;
        weekdaysScrollView.showsHorizontalScrollIndicator = NO;
        
        _weekdaysScrollView = weekdaysScrollView;
        [self addSubview:weekdaysScrollView];
    }
    
    return _weekdaysScrollView;
}

- (NSArray*)weekdayLabels
{
    if (!_weekdayLabels) {
        _weekdayLabels = [self createWeekdayLabels];
    }
    
    return _weekdayLabels;
}

// Instantiate date views together to avoid race conditions
- (NSArray*)currentDateViews
{
    if (!_currentDateViews) {
        _currentDateViews = [self createDateViewsForWeek:self.weekdays];
        _leftDateViews = [self createDateViewsForWeek:self.prevWeekdays];
        _rightDateViews = [self createDateViewsForWeek:self.nextWeekdays];
    }
    
    return _currentDateViews;
}

- (NSArray*)leftDateViews
{
    if (!_leftDateViews) {
        _currentDateViews = [self createDateViewsForWeek:self.weekdays];
        _leftDateViews = [self createDateViewsForWeek:self.prevWeekdays];
        _rightDateViews = [self createDateViewsForWeek:self.nextWeekdays];
    }
    
    return _leftDateViews;
}

- (NSArray*)rightDateViews
{
    if (!_rightDateViews) {
        _currentDateViews = [self createDateViewsForWeek:self.weekdays];
        _leftDateViews = [self createDateViewsForWeek:self.prevWeekdays];
        _rightDateViews = [self createDateViewsForWeek:self.nextWeekdays];
    }
    
    return _rightDateViews;
}


#pragma mark - Creating Views

- (NSArray*)createWeekdayLabels
{
    NSMutableArray* mutableWeekdayLabels = [[NSMutableArray alloc] init];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    for (NSInteger i = 0; i < calendar.shortWeekdaySymbols.count; i++) {
        UILabel* weekdayLabel = [self addLabel];
        
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.font = [UIFont systemFontOfSize:11.0f];
        weekdayLabel.text = calendar.shortWeekdaySymbols[i];
        
        weekdayLabel.layer.borderWidth = 1.0f;
        
        [mutableWeekdayLabels addObject:weekdayLabel];
    }
    
    return [mutableWeekdayLabels copy];
}

- (NSArray*)createDateViewsForWeek:(NSArray*)weekdays
{
    NSMutableArray* mutableDateViews = [[NSMutableArray alloc] init];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    ECDateViewFactory* factory = [[ECDateViewFactory alloc] init];
    for (NSDate* date in weekdays) {
        ECDateView* dateView = [factory dateViewForDate:date];
        
        [dateView addTarget:self action:@selector(dateViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([calendar isDate:date inSameDayAsDate:self.selectedDate]) {
            [self selectDateView:dateView animated:NO];
        }
        
        [self.weekdaysScrollView addSubview:dateView];
        [mutableDateViews addObject:dateView];
    }
    
    return [mutableDateViews copy];
}


#pragma mark - Setting Weekdays

- (void)updateWeekdaysWithDate:(NSDate*)date
{
    self.weekdays = [self weekdaysForDate:date];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    self.prevWeekdays = [self weekdaysForDate:[calendar dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:date options:0]];
    self.nextWeekdays = [self weekdaysForDate:[calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:date options:0]];
}

- (NSArray*)weekdaysForDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* startOfWeek;
    
    // grab first day of week containing date
    [calendar rangeOfUnit:NSCalendarUnitWeekday startDate:&startOfWeek interval:nil forDate:date];
    
    DDLogDebug(@"Weekday Picker - Date: %@, First day of week: %@", date, startOfWeek);
    
    NSMutableArray* mutableWeekdays = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 7; i++) {
        NSDate* date = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:startOfWeek options:0];
        
        [mutableWeekdays addObject:date];
    }
    
    return [mutableWeekdays copy];
}

- (void)scrollToWeekContainingDate:(NSDate *)date
{
    NSArray* oldWeekdays = [self.weekdays copy];
    [self updateWeekdaysWithDate:date];
    
    [self.pickerDelegate weekdayPicker:self didScrollFrom:oldWeekdays to:self.weekdays];
}

#pragma mark - UI Events

- (void)dateViewTapped:(ECDateView*)dateView
{
    if (!dateView.isSelectedDate) {
        [self setSelectedDate:dateView.date animated:YES];

        [self.selectedDateView setSelectedDate:NO animated:YES];
        [self selectDateView:dateView animated:YES];
    }
}

- (void)selectDateView:(ECDateView*)dateView animated:(BOOL)animated
{
    self.selectedDateView = dateView;
    [dateView setSelectedDate:YES animated:animated];
}

#pragma mark - Layout

#define WEEKDAY_LABEL_HEIGHT   22.0f

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutWeekdayLabels];
    [self layoutWeekdayScrollView];
}

- (void)layoutWeekdayLabels
{
    CGFloat weekdayLabelWidth = floorf(self.bounds.size.width / self.weekdayLabels.count);
    
    for (NSInteger i = 0; i < self.weekdayLabels.count; i++) {
        CGRect weekdayLabelFrame = CGRectMake(self.bounds.origin.x + i * weekdayLabelWidth,
                                              self.bounds.origin.y,
                                              weekdayLabelWidth,
                                              WEEKDAY_LABEL_HEIGHT);
        
        UILabel* weekdayLabel = self.weekdayLabels[i];
        weekdayLabel.frame = weekdayLabelFrame;
    }
}

- (void)layoutWeekdayScrollView
{
    UILabel* firstWeekdayLabel = [self.weekdayLabels firstObject];
    
    CGRect weekdayScrollViewFrame = CGRectMake(self.bounds.origin.x,
                                               CGRectGetMaxY(firstWeekdayLabel.frame),
                                               self.bounds.size.width,
                                               self.bounds.size.height - WEEKDAY_LABEL_HEIGHT);
    
    self.weekdaysScrollView.frame = weekdayScrollViewFrame;
    self.weekdaysScrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height - WEEKDAY_LABEL_HEIGHT);
    
    [self layoutDateViews];
    self.weekdaysScrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
}

- (void)layoutDateViews
{
    CGRect leftDateViewsBounds = CGRectMake(self.weekdaysScrollView.bounds.origin.x,
                                            self.weekdaysScrollView.bounds.origin.y,
                                            self.bounds.size.width,
                                            self.weekdaysScrollView.bounds.size.height);
    [self layoutDateViews:self.leftDateViews inRect:leftDateViewsBounds];
    
    CGRect currentDateViewBounds = CGRectMake(self.weekdaysScrollView.bounds.origin.x + self.bounds.size.width,
                                              self.weekdaysScrollView.bounds.origin.y,
                                              self.bounds.size.width,
                                              self.weekdaysScrollView.bounds.size.height);
    [self layoutDateViews:self.currentDateViews inRect:currentDateViewBounds];
    
    CGRect rightDateViewBounds = CGRectMake(self.weekdaysScrollView.bounds.origin.x + 2 * self.bounds.size.width,
                                            self.weekdaysScrollView.bounds.origin.y,
                                            self.weekdaysScrollView.bounds.size.width,
                                            self.weekdaysScrollView.bounds.size.height);
    [self layoutDateViews:self.rightDateViews inRect:rightDateViewBounds];

}

- (void)layoutDateViews:(NSArray*)dateViews inRect:(CGRect)rect
{
    CGFloat dateViewWidth = floorf(rect.size.width / dateViews.count);

    for (NSInteger i = 0; i < dateViews.count; i++) {
        CGRect dateViewFrame = CGRectMake(rect.origin.x + i * dateViewWidth, rect.origin.y, dateViewWidth, rect.size.height);
        
        ECDateView* dateView = dateViews[i];
        dateView.frame = dateViewFrame;
    }
}




@end
