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

@interface ECWeekdayPicker() <UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) NSDate* selectedDate;

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

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    DDLogDebug(@"Waking ECWeekdayPicker from nib");
    [super awakeFromNib];
}

- (instancetype)initWithDate:(NSDate *)date
{
    DDLogDebug(@"Initializing weekday picker with date %@", date);
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setSelectedDate:date animated:YES];
    }
    
    return self;
}


#pragma mark - Properties

#pragma mark Selected Date

- (void)setSelectedDate:(NSDate *)selectedDate
{
    DDLogDebug(@"Changing weekday picker selected date from %@ to %@", _selectedDate, selectedDate);
    _selectedDate = selectedDate;
    
    [self updateSelectedDateView:NO];
    [self informDelegateSelectedDateChanged:selectedDate];
}

- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated
{
    DDLogDebug(@"Changing weekday picker selected date from %@ to %@", _selectedDate, selectedDate);
    _selectedDate = selectedDate;
    [self updateWeekdaysWithDate:selectedDate];
    [self updateSelectedDateView:animated];
    [self setNeedsLayout];
    
    [self informDelegateSelectedDateChanged:selectedDate];
}

- (void)updateSelectedDateView:(BOOL)animated
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    [self.selectedDateView setSelectedDate:NO animated:animated];
    for (ECDateView* dateView in self.currentDateViews) {
        if ([calendar isDate:dateView.date inSameDayAsDate:self.selectedDate]) {
            DDLogDebug(@"Changing selected date view to view with date %@", dateView.date);
            [self selectDateView:dateView animated:NO];
        }
    }
}

#pragma mark Views
- (UIScrollView *)weekdaysScrollView
{
    if (!_weekdaysScrollView) {
        UIScrollView* weekdaysScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        
        weekdaysScrollView.pagingEnabled = YES;
        weekdaysScrollView.showsHorizontalScrollIndicator = NO;
        weekdaysScrollView.delegate = self;
        
        _weekdaysScrollView = weekdaysScrollView;
        [self addSubview:weekdaysScrollView];
    }
    
    return _weekdaysScrollView;
}

// Instantiate date views together to avoid race conditions
- (NSArray*)currentDateViews
{
    if (!_currentDateViews) {
        [self createDateViews];
    }
    
    return _currentDateViews;
}

- (NSArray*)leftDateViews
{
    if (!_leftDateViews) {
        [self createDateViews];
    }
    
    return _leftDateViews;
}

- (NSArray*)rightDateViews
{
    if (!_rightDateViews) {
        [self createDateViews];
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

- (void)createDateViews
{
    _currentDateViews = [self createDateViewsForWeek:self.weekdays];
    _leftDateViews = [self createDateViewsForWeek:self.prevWeekdays];
    _rightDateViews = [self createDateViewsForWeek:self.nextWeekdays];
}

- (NSArray*)createDateViewsForWeek:(NSArray*)weekdays
{
    NSMutableArray* mutableDateViews = [[NSMutableArray alloc] init];
    
    ECDateViewFactory* factory = [[ECDateViewFactory alloc] init];
    for (NSDate* date in weekdays) {
        ECDateView* dateView = [factory dateViewForDate:date];
        
        [dateView addTarget:self action:@selector(dateViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.weekdaysScrollView addSubview:dateView];
        [mutableDateViews addObject:dateView];
    }
    
    return [mutableDateViews copy];
}


#pragma mark - Setting Weekdays

- (void)updateWeekdaysWithDate:(NSDate*)date
{
    DDLogDebug(@"Updating weekdays with date %@", date);
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
    DDLogDebug(@"Scrolling to week containing date %@", date);
    NSArray* oldWeekdays = [self.weekdays copy];
    [self updateWeekdaysWithDate:date]; // alters current weekdays
    NSArray* newWeekdays = [self.weekdays copy];
    
    [self informDelegatePickerScrolledFrom:oldWeekdays to:newWeekdays];
}

#pragma mark - UI Events

- (void)dateViewTapped:(ECDateView*)dateView
{
    DDLogDebug(@"Date view tapped");
    if (!dateView.isSelectedDate) {
        [self setSelectedDate:dateView.date animated:YES];
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
    DDLogDebug(@"Left Date Views Bounds %@", NSStringFromCGRect(leftDateViewsBounds));
    [self layoutDateViews:self.leftDateViews inRect:leftDateViewsBounds];
    
    CGRect currentDateViewsBounds = CGRectMake(self.weekdaysScrollView.bounds.origin.x + self.bounds.size.width,
                                              self.weekdaysScrollView.bounds.origin.y,
                                              self.bounds.size.width,
                                              self.weekdaysScrollView.bounds.size.height);
    DDLogDebug(@"Current Date View Bounds %@", NSStringFromCGRect(currentDateViewsBounds));
    [self layoutDateViews:self.currentDateViews inRect:currentDateViewsBounds];
    
    CGRect rightDateViewsBounds = CGRectMake(self.weekdaysScrollView.bounds.origin.x + 2 * self.bounds.size.width,
                                            self.weekdaysScrollView.bounds.origin.y,
                                            self.weekdaysScrollView.bounds.size.width,
                                            self.weekdaysScrollView.bounds.size.height);
    DDLogDebug(@"Right Date Views Bounds %@", NSStringFromCGRect(rightDateViewsBounds));
    [self layoutDateViews:self.rightDateViews inRect:rightDateViewsBounds];

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


#pragma mark - Scroll View Delegate

typedef NS_ENUM(NSInteger, ECWeekdayPickerScrollDirection) {
    ECWeekdayPickerScrollDirectionLeft = 1,
    ECWeekdayPickerScrollDirectionRight = -1,
};

- (CGPoint)weekdayPickerCenterOffset
{
    CGFloat centerX = (self.weekdaysScrollView.contentSize.width - self.weekdaysScrollView.bounds.size.width) / 2;
    
    return CGPointMake(centerX, self.weekdaysScrollView.bounds.origin.y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint centerOffset = [self weekdayPickerCenterOffset];
    
    CGFloat offsetDelta = centerOffset.x - scrollView.contentOffset.x;
    if (fabs(offsetDelta) > self.weekdaysScrollView.bounds.size.width / 2) {
        
        ECWeekdayPickerScrollDirection direction = (offsetDelta < 0) ? ECWeekdayPickerScrollDirectionLeft : ECWeekdayPickerScrollDirectionRight;
        [self moveWeekdaysOneWeek:direction];
    }
}


#pragma mark - Changing visible weekdays

- (void)moveWeekdaysOneWeek:(ECWeekdayPickerScrollDirection)direction
{
    NSArray* oldWeekdays = [self.weekdays copy]; // create a copy before swapping
    switch (direction) {
        case ECWeekdayPickerScrollDirectionLeft:
            [self moveWeekdaysForwardsOneWeek];
            break;
            
        case ECWeekdayPickerScrollDirectionRight:
            [self moveWeekdaysBackwardsOneWeek];
            break;
            
        default:
            DDLogError(@"Unrecognized direction %lu", direction);
            break;
    }
    
    NSArray* newWeekdays = [self.weekdays copy]; // pass a copy to keep weekdays readonly
    [self informDelegatePickerScrolledFrom:oldWeekdays to:newWeekdays];

    BOOL selectedTodaysDate = NO;
    NSDate* today = [NSDate date];
    for (NSDate* date in self.weekdays) {
        if ([[NSCalendar currentCalendar] isDate:date inSameDayAsDate:today]) {
            self.selectedDate = date;
            selectedTodaysDate = YES;
        }
    }
    if (!selectedTodaysDate) {
        self.selectedDate = self.weekdays.firstObject;
    }
    
    [self layoutWeekdayScrollView];
}

- (void)moveWeekdaysForwardsOneWeek
{
    DDLogDebug(@"Moving weekdays forward one week");
    [self swapCurrentWeekdaysWithNext];
    [self swapCurrentDateViewsWithRight];
}

- (void)moveWeekdaysBackwardsOneWeek
{
    DDLogDebug(@"Moving weekdays backward one week");
    [self swapCurrentWeekdaysWithPrevious];
    [self swapCurrentDateViewsWithLeft];
}

- (void)changeWeekdays:(NSArray*)weekdays previous:(NSArray*)previousWeekdays next:(NSArray*)nextWeekdays
{
    self.weekdays = weekdays;
    self.prevWeekdays = previousWeekdays;
    self.nextWeekdays = nextWeekdays;
}

- (void)swapCurrentWeekdaysWithPrevious
{
    self.nextWeekdays = self.weekdays; // move current to next
    self.weekdays = self.prevWeekdays; // move previous to current
    
    // load new next weekdays
    NSCalendar* calendar = [NSCalendar currentCalendar];
    self.prevWeekdays = [self weekdaysForDate:[calendar dateByAddingUnit:NSCalendarUnitDay value:-7 toDate:self.weekdays.firstObject options:0]];
}

- (void)swapCurrentDateViewsWithLeft
{
    NSArray* temp = self.rightDateViews;
    self.rightDateViews = self.currentDateViews;
    self.currentDateViews = self.leftDateViews;
    self.leftDateViews = temp;
    
    [ECWeekdayPicker updateDateViews:self.leftDateViews withDates:self.prevWeekdays];
}

- (void)swapCurrentWeekdaysWithNext
{
    self.prevWeekdays = self.weekdays; // move current weekdays to previous
    self.weekdays = self.nextWeekdays; // move next into current
    
    // load new previous weekdays
    NSCalendar* calendar = [NSCalendar currentCalendar];
    self.nextWeekdays = [self weekdaysForDate:[calendar dateByAddingUnit:NSCalendarUnitDay value:7 toDate:self.weekdays.firstObject options:0]];
}

- (void)swapCurrentDateViewsWithRight
{
    NSArray* temp = self.leftDateViews;
    self.leftDateViews = self.currentDateViews;
    self.currentDateViews = self.rightDateViews;
    self.rightDateViews = temp;
    
    [ECWeekdayPicker updateDateViews:self.rightDateViews withDates:self.nextWeekdays];
}

+ (void)updateDateViews:(NSArray*)dateViews withDates:(NSArray*)dates
{
    for (NSInteger i = 0; i < dateViews.count; i++) {
        ECDateView* dateView = dateViews[i];
        NSDate* date = dates[i];
        dateView.date = date;
    }
}

#pragma mark - Delegate

- (void)informDelegateSelectedDateChanged:(NSDate*)selectedDate
{
    if ([self.pickerDelegate respondsToSelector:@selector(weekdayPicker:didSelectDate:)]) {
        [self.pickerDelegate weekdayPicker:self didSelectDate:selectedDate];
    }
}

- (void)informDelegatePickerScrolledFrom:(NSArray*)oldWeekdays to:(NSArray*)newWeekdays
{
    if ([self.pickerDelegate respondsToSelector:@selector(weekdayPicker:didScrollFrom:to:)]) {
        [self.pickerDelegate weekdayPicker:self didScrollFrom:oldWeekdays to:newWeekdays];
    }
}
@end
