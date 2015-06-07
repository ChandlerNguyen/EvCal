//
//  ECWeekdayPicker.m
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "NSDate+CupertinoYankee.h"
#import "UIView+ECAdditions.h"
#import "ECWeekdayPicker.h"
#import "ECDateView.h"
#import "ECDateViewFactory.h"


#define DATE_PICKER_CELL_REUSE_ID   @"DatePickerCell"

@interface ECWeekdayPicker()

@property (nonatomic, strong) NSDateFormatter* dateFormatter;

// views
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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (instancetype)initWithDate:(NSDate *)date
{
    DDLogDebug(@"Initializing weekday picker with date %@", date);
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setup];
        
        [self setSelectedDate:date animated:YES];
    }
    
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
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
    NSDate* startOfWeek = [date beginningOfWeek];
    
    DDLogDebug(@"Weekday Picker - Date: %@, First day of week: %@", date, startOfWeek);
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
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

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self layoutWeekdayScrollView];
}

- (void)layoutWeekdayScrollView
{
    CGRect weekdayScrollViewFrame = CGRectMake(self.bounds.origin.x,
                                               self.bounds.origin.y,
                                               self.bounds.size.width,
                                               self.bounds.size.height);
    CGSize weekdayScrollViewContentSize = CGSizeMake(weekdayScrollViewFrame.size.width * 3, weekdayScrollViewFrame.size.height);
    
    DDLogDebug(@"Weekday Scroll View Frame: %@", NSStringFromCGRect(weekdayScrollViewFrame));
    DDLogDebug(@"Weekday Scroll View Content Size: %@", NSStringFromCGSize(weekdayScrollViewContentSize));
    self.weekdaysScrollView.frame = weekdayScrollViewFrame;
    self.weekdaysScrollView.contentSize = weekdayScrollViewContentSize;
    
    self.weekdaysScrollView.contentOffset = CGPointZero; // recenter before laying out date views
    [self layoutDateViews];
    self.weekdaysScrollView.contentOffset = CGPointMake(self.weekdaysScrollView.bounds.size.width, 0); // set to middle view
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
        CGRect dateViewFrame = CGRectMake(rect.origin.x + i * dateViewWidth,
                                          rect.origin.y,
                                          dateViewWidth,
                                          rect.size.height);
        
        DDLogDebug(@"Date View Frame: %@", NSStringFromCGRect(dateViewFrame));
        ECDateView* dateView = dateViews[i];
        dateView.frame = dateViewFrame;
    }
}




@end
