//
//  ECInfiniteHorizontalDatePagingView.m
//  EvCal
//
//  Created by Tom on 6/18/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECInfiniteHorizontalDatePagingView.h"

@interface ECInfiniteHorizontalDatePagingView()

@property (nonatomic, strong) NSMutableArray* pages;
@property (nonatomic, weak) UIView* pageContainerView;

@end

@implementation ECInfiniteHorizontalDatePagingView

#pragma mark - Properties and Lifecycle

- (instancetype)initWithFrame:(CGRect)frame date:(NSDate *)date
{
    self = [super initWithFrame:frame];

    if (self) {
        self.calendarUnit = NSCalendarUnitDay;
        self.date = date;
        self.pagingEnabled = YES;
    }
    
    return self;
}


#pragma mark Public
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (self.pageView) {
        CGSize threePageContentSize = CGSizeMake(frame.size.width * 3, frame.size.height);
        [super setContentSize:threePageContentSize];
        
        [self resetContainerFrame];
        [self resetPageFrames];
    }
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    DDLogWarn(@"The infinite horizontal pager should always be in paging mode");
    [super setPagingEnabled:YES];
}

- (void)setDate:(NSDate *)date
{
    DDLogDebug(@"Changing date from: %@ to: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:_date], [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    NSDate* oldDate = _date;
    _date = date;
    
    [self refreshPages];
    
    if ([self.pageViewDelegate respondsToSelector:@selector(infiniteDateView:dateChangedTo:from:)]) {
        [self.pageViewDelegate infiniteDateView:self dateChangedTo:date from:oldDate];
    }
}

- (void)setPageViewDataSource:(id<ECInfiniteHorizontalDatePagingViewDataSource>)pageViewDataSource
{
    _pageViewDataSource = pageViewDataSource;
    
    [self clearPages];
}

- (UIView*)pageView
{
    if (!_pageView) {
        UIView* pageView = [self getPageView];
        _pageView = pageView;
        [self.pageContainerView addSubview:pageView];
    }
    
    return _pageView;
}

- (UIView*)pageContainerView
{
    if (!_pageContainerView) {
        UIView* pageContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _pageContainerView = pageContainerView;
        [self addSubview:pageContainerView];
        [self resetContainerFrame];
    }
    
    return _pageContainerView;
}

#pragma mark Private

- (NSMutableArray*)pages
{
    if (!_pages) {
        _pages = [[NSMutableArray alloc] init];
        
        [_pages addObjectsFromArray:[self createPages]];
    }
    
    return _pages;
}

- (NSMutableArray*)createPages
{
    NSMutableArray* pages = [[NSMutableArray alloc] init];
    [pages addObject:self.pageView];
    
    UIView* leftPageView = [[[self.pageView class] alloc] initWithFrame:self.bounds];
    UIView* rightPageView = [[[self.pageView class] alloc] initWithFrame:self.bounds];
    
    [self.pageContainerView addSubview:leftPageView];
    [self.pageContainerView addSubview:rightPageView];
    
    [pages insertObject:leftPageView atIndex:0];
    [pages addObject:rightPageView];
    
    return pages;
}


#pragma mark - Layout

#define LEFT_PAGE_INDEX     0
#define CENTER_PAGE_INDEX   1
#define RIGHT_PAGE_INDEX    2

- (void)resetContainerFrame
{
    self.contentOffset = CGPointMake(self.contentSize.width / 3.0f, 0);
    CGRect pageContainerFrame = CGRectMake(self.bounds.origin.x - self.contentOffset.x,
                                           self.bounds.origin.y,
                                           self.contentSize.width,
                                           self.contentSize.height);
    
    self.pageContainerView.frame = pageContainerFrame;
}

- (void)resetPageFrames
{
    for (NSInteger i = 0; i < self.pages.count; i++) {
        UIView* page = self.pages[i];
        
        CGRect pageFrame = CGRectMake(self.bounds.origin.x - self.contentOffset.x + i * (self.contentSize.width / 3.0f),
                                      self.bounds.origin.y,
                                      self.bounds.size.width,
                                      self.bounds.size.height);
        
        
        pageFrame.size = self.bounds.size;
        page.frame = pageFrame;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL didRecenter = [self recenterIfNecessary];

    if (didRecenter) {
        [self changePageDates];
    }
}

- (BOOL)recenterIfNecessary
{
    CGPoint currentOffset = [self contentOffset];
    CGFloat pageWidth = self.contentSize.width / 3.0f;
    
    BOOL recenter = fabs(currentOffset.x - pageWidth) > (pageWidth / 2.0f);
    
    if (recenter) {
        CGFloat contentDelta;
        if (currentOffset.x - pageWidth > 0) {
            contentDelta = -pageWidth;
        } else {
            contentDelta = pageWidth;
        }
        
        self.contentOffset = CGPointMake(currentOffset.x + contentDelta, currentOffset.y);
        for (UIView* page in self.pages) {
            CGRect pageFrame = page.frame;
            pageFrame.origin.x += contentDelta;
            page.frame = pageFrame;
        }
    }
    
    return recenter;
}

- (void)changePageDates
{
    UIView* leftPageView = self.pages[LEFT_PAGE_INDEX];
    UIView* rightPageView = self.pages[RIGHT_PAGE_INDEX];
    
    CGFloat pageWidth = self.contentSize.width / 3.0f;
    if (leftPageView.frame.origin.x < self.bounds.origin.x - pageWidth) {
        DDLogDebug(@"Left page scrolled out of container");
        [self movePageAtIndex:LEFT_PAGE_INDEX toIndex:RIGHT_PAGE_INDEX];
    } else if (CGRectGetMaxX(rightPageView.frame) > CGRectGetMaxX(self.bounds) + pageWidth) {
        DDLogDebug(@"Right page scrolled out of container");
        [self movePageAtIndex:RIGHT_PAGE_INDEX toIndex:LEFT_PAGE_INDEX];
    }
}

- (void)movePageAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    DDLogDebug(@"Moving from index %d to index %d", (int)fromIndex, (int)toIndex);
    // calculate new date for moved page
    NSInteger movedPageDateDelta = toIndex - fromIndex;
    NSDate* movedPageDate = [[NSCalendar currentCalendar] dateByAddingUnit:self.calendarUnit value:movedPageDateDelta toDate:self.date options:0];
    DDLogDebug(@"New date from moved page: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:movedPageDate]);
    
    // get updated page from data source
    [self.pageViewDataSource infiniteDateView:self preparePage:self.pages[fromIndex] forDate:movedPageDate];
    
    UIView* movedPage = self.pages[fromIndex];
    [self.pages removeObject:movedPage];
    [self.pages insertObject:movedPage atIndex:toIndex];
    
    CGRect movedPageFrame = CGRectMake(self.pageContainerView.bounds.origin.x + toIndex * self.contentSize.width / 3.0f,
                                       self.pageContainerView.bounds.origin.y,
                                       self.bounds.size.width,
                                       self.bounds.size.height);
    movedPage.frame = movedPageFrame;
    
    // update current date
    NSInteger centeredPageDateDelta = toIndex - CENTER_PAGE_INDEX;
    NSDate* centeredPageDate = [[NSCalendar currentCalendar] dateByAddingUnit:self.calendarUnit value:centeredPageDateDelta toDate:self.date options:0];
    DDLogDebug(@"New centered page date: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:centeredPageDate]);
    
    self.date = centeredPageDate;
}


#pragma mark - Page Control

- (UIView*)getPageView
{
    if (self.pageViewDataSource) {
        return [self.pageViewDataSource pageViewForInfiniteDateView:self];
    } else {
        return [[UIView alloc] initWithFrame:self.bounds];
    }
}

- (void)refreshPages
{
    if (self.date) {
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* leftPageDate = [calendar dateByAddingUnit:self.calendarUnit value:-1 toDate:self.date options:0];
        NSDate* rightPageDate = [calendar dateByAddingUnit:self.calendarUnit value:1 toDate:self.date options:0];
        
        DDLogDebug(@"Left page date: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:leftPageDate]);
        DDLogDebug(@"Right page date: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:rightPageDate]);
        
        [self.pageViewDataSource infiniteDateView:self preparePage:self.pages[LEFT_PAGE_INDEX] forDate:leftPageDate];
        [self.pageViewDataSource infiniteDateView:self preparePage:self.pages[CENTER_PAGE_INDEX] forDate:self.date];
        [self.pageViewDataSource infiniteDateView:self preparePage:self.pages[RIGHT_PAGE_INDEX] forDate:rightPageDate];
    }
}

- (void)clearPages
{
    for (UIView* pageView in self.pages) {
        [pageView removeFromSuperview];
    }
    
    self.pages = nil;
}

@end
