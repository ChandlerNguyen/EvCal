//
//  ECWeekdayPicker.m
//  EvCal
//
//  Created by Tom on 5/29/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECWeekdayPicker.h"
#import "ECDatePickerCell.h"

#define DATE_PICKER_CELL_REUSE_ID   @"DatePickerCell"

@interface ECWeekdayPicker() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView* weekdaysCollectionView;

// weekday arrays
@property (nonatomic, strong, readwrite) NSArray* weekdays;
@property (nonatomic, strong) NSArray* prevWeekdays;
@property (nonatomic, strong) NSArray* nextWeekdays;

@end

@implementation ECWeekdayPicker

#pragma mark - Lifecycle and Properties

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setSelectedDate:date animated:YES];
        
        [self addWeekdaysCollectionView];
    }
    
    return self;
}

- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated
{
    _selectedDate = selectedDate;
    [self updateWeekdaysWithDate:selectedDate];
    
    [self.pickerDelegate weekdayPicker:self didSelectDate:selectedDate];
}

- (void)addWeekdaysCollectionView
{
    UICollectionViewLayout* flow = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView* weekdaysCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    
    weekdaysCollectionView.pagingEnabled = YES;
    weekdaysCollectionView.delegate = self;
    weekdaysCollectionView.dataSource = self;
    
    [weekdaysCollectionView registerClass:[ECDatePickerCell class] forCellWithReuseIdentifier:DATE_PICKER_CELL_REUSE_ID];
    
    self.weekdaysCollectionView = weekdaysCollectionView;
    [self addSubview:weekdaysCollectionView];
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


#pragma mark - Configuring Collection View Cells

#define LAST_WEEK_SECTION 0
#define CURRENT_WEEK_SECTION 1
#define NEXT_WEEK_SECTION 2

- (void)configureCell:(ECDatePickerCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case LAST_WEEK_SECTION:
            cell.date = self.prevWeekdays[indexPath.row];
            break;
            
        case CURRENT_WEEK_SECTION:
            cell.date = self.weekdays[indexPath.row];
            break;
            
        case NEXT_WEEK_SECTION:
            cell.date = self.nextWeekdays[indexPath.row];
            break;
            
        default:
            DDLogError(@"Invalid index path for collection view, indexPath: %@", indexPath);
            break;
    }
}


#pragma mark - UI Collection View Delegate and Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ECDatePickerCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DATE_PICKER_CELL_REUSE_ID forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // pass
}

@end
