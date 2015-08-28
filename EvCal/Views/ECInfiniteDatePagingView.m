//
//  ECInfiniteDatePagingView.m
//  EvCal
//
//  Created by Tom on 6/18/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECInfiniteDatePagingView.h"

@interface ECInfiniteDatePagingView() <UIScrollViewDelegate>

@property (nonatomic, strong) NSCalendar* calendar;
@property (nonatomic, strong, readonly) NSDate* centerPageDate;

@property (nonatomic, weak) UIView* pageContainerView;
@property (nonatomic, strong, readwrite) NSArray* pages;

@property (nonatomic) BOOL scrollingToDate;
@property (nonatomic, weak) ECDatePage* pageView;

@end

@implementation ECInfiniteDatePagingView

#pragma mark - Properties and Lifecycle
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}
- (instancetype)initWithFrame:(CGRect)frame date:(NSDate *)date
{
    self = [super initWithFrame:frame];

    if (self) {
        DDLogDebug(@"Initalized with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
        self.date = date;
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.calendarUnit = NSCalendarUnitDay;
    self.pageDateDelta = 1;
    self.delegate = self;
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}


#pragma mark Public
- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    self.scrollingToDate = NO;
    
    if (self.pageView && !CGRectEqualToRect(oldFrame, frame)) {
        CGSize threePageContentSize = CGSizeMake(frame.size.width * 3, frame.size.height);
        self.contentSize = threePageContentSize;
        self.contentOffset = CGPointMake(frame.size.width, self.bounds.origin.y);
        
        [self resetContainerFrame];
        [self resetPageFrames];
    }
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    if (!pagingEnabled)
        DDLogWarn(@"The infinite horizontal pager should always be in paging mode");

    [super setPagingEnabled:YES];
}

- (void)setDate:(NSDate *)date
{
    DDLogDebug(@"Changing date to: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
    NSDate* oldDate = _date;
    _date = date;
    
    [self informDelegateDateChangedFromDate:oldDate toDate:date];
}

- (NSDate*)centerPageDate
{
    ECDatePage* centerPage = self.pages[kPageCenterIndex];
    return centerPage.date;
}

- (NSCalendar*)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar autoupdatingCurrentCalendar];
    }
    
    return _calendar;
}

- (void)setPageViewDataSource:(id<ECInfiniteDatePagingViewDataSource>)pageViewDataSource
{
    _pageViewDataSource = pageViewDataSource;
    
    [self clearPages];
    [self refreshPages];
}

- (ECDatePage*)pageView
{
    if (!_pageView) {
        ECDatePage* pageView = [self getPageView];
        pageView.date = self.date;
        _pageView = pageView;
        [self.pageContainerView addSubview:pageView];
    }
    
    return _pageView;
}

- (UIView*)visiblePage
{
    return self.pages[kPageCenterIndex];
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

- (NSArray*)pages
{
    if (!_pages) {
        NSMutableArray* mutablePages = [[NSMutableArray alloc] init];
        
        [mutablePages addObjectsFromArray:[self createPages]];
        
        _pages = [mutablePages copy];
    }
    
    return _pages;
}

- (NSMutableArray*)createPages
{
    DDLogDebug(@"Creating pages");
    NSMutableArray* pages = [[NSMutableArray alloc] init];
    [pages addObject:self.pageView];
    
    ECDatePage* leftPageView = [[[self.pageView class] alloc] initWithFrame:self.bounds];
    ECDatePage* rightPageView = [[[self.pageView class] alloc] initWithFrame:self.bounds];
    
    leftPageView.date = [self.calendar dateByAddingUnit:self.calendarUnit value:-1 * self.pageDateDelta toDate:self.date options:0];
    rightPageView.date = [self.calendar dateByAddingUnit:self.calendarUnit value:1 * self.pageDateDelta toDate:self.date options:0];
    
    [self.pageContainerView addSubview:leftPageView];
    [self.pageContainerView addSubview:rightPageView];
    
    [pages insertObject:leftPageView atIndex:0];
    [pages addObject:rightPageView];
    
    return pages;
}


#pragma mark - Layout

- (void)resetContainerFrame
{
    CGRect pageContainerFrame = CGRectMake(self.bounds.origin.x - self.contentOffset.x,
                                           0.0f,
                                           self.contentSize.width,
                                           self.contentSize.height);
    
    self.pageContainerView.frame = pageContainerFrame;
}

- (void)resetPageFrames
{
    for (NSInteger i = 0; i < self.pages.count; i++) {
        UIView* page = self.pages[i];
        
        CGRect pageFrame = CGRectMake(self.bounds.origin.x - self.contentOffset.x + i * (self.contentSize.width / 3.0f),
                                      0.0f,
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
        if (!self.scrollingToDate) {
            [self updatePageIndices];
        }
        [self resetPageFrames];
    } else {
        
    }
}

- (BOOL)recenterIfNecessary
{
    CGPoint currentOffset = self.contentOffset;
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
        
        self.scrollEnabled = YES;
    }
    
    return recenter;
}

- (void)updatePageIndices
{
    ECDatePage* leftPageView = self.pages[kPageLeftIndex];
    ECDatePage* rightPageView = self.pages[kPageRightIndex];
    
    CGFloat pageWidth = self.contentSize.width / 3.0f;
    if (leftPageView.frame.origin.x < self.bounds.origin.x - pageWidth) {
        DDLogDebug(@"Left page scrolled out of container");
        [self movePageAtIndex:kPageLeftIndex toIndex:kPageRightIndex];
        DDLogDebug(@"Changing date to center date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:self.centerPageDate]);
        self.date = self.centerPageDate;
        [self updatePageAtIndex:kPageRightIndex];
    } else if (CGRectGetMaxX(rightPageView.frame) > CGRectGetMaxX(self.bounds) + pageWidth) {
        DDLogDebug(@"Right page scrolled out of container");
        [self movePageAtIndex:kPageRightIndex toIndex:kPageLeftIndex];
        DDLogDebug(@"Changing date to center date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:self.centerPageDate]);
        self.date = self.centerPageDate;
        [self updatePageAtIndex:kPageLeftIndex];
    }
}

static NSInteger kPageNotFoundIndex = -1;
static NSInteger kPageLeftIndex = 0;
static NSInteger kPageCenterIndex = 1;
static NSInteger kPageRightIndex = 2;

- (void)movePageAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    DDLogDebug(@"Moving page from index %lu to index %lu", (long)fromIndex, (long)toIndex);
    UIView* movedPage = self.pages[fromIndex];
    
    NSMutableArray* mutablePages = [self.pages mutableCopy];
    [mutablePages removeObject:movedPage];
    [mutablePages insertObject:movedPage atIndex:toIndex];
    self.pages = [mutablePages copy];
    
    [self informDelegateVisiblePageChangedTo:self.pages[kPageCenterIndex]];
}

- (void)updatePageAtIndex:(NSInteger)index
{
    DDLogDebug(@"Updating page at index %lu", (long)index);
    ECDatePage* changeDatePage = self.pages[index];
    changeDatePage.date = [self.calendar dateByAddingUnit:self.calendarUnit value:(index - kPageCenterIndex) * self.pageDateDelta toDate:self.date options:0];
    DDLogDebug(@"Page date changed to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:changeDatePage.date]);
    [self.pageViewDataSource infiniteDateView:self preparePage:changeDatePage];
}

- (void)updatePageDates
{
    for (NSInteger i = 0; i < self.pages.count; i++) {
        ECDatePage* page = self.pages[i];
        page.date = [self.calendar dateByAddingUnit:self.calendarUnit value:(i - kPageCenterIndex) * self.pageDateDelta toDate:self.date options:0];
        DDLogDebug(@"Page at index %lu date changed to %@", (long)i, [[ECLogFormatter logMessageDateFormatter] stringFromDate:page.date]);
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    if (date && ![self.calendar isDate:date equalToDate:self.date toUnitGranularity:self.calendarUnit]) {
        DDLogDebug(@"Scrolling to date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
        self.date = date;
        
        if (![self.calendar isDate:date equalToDate:self.centerPageDate toUnitGranularity:self.calendarUnit]) {
            NSComparisonResult dateOrder = [date compare:self.centerPageDate];
            switch (dateOrder) {
                case NSOrderedAscending: // scroll to date prior to current date
                    self.scrollingToDate = YES;
                    [self movePageAtIndex:kPageRightIndex toIndex:kPageLeftIndex];
                    [self updatePageDates];
                    [self scrollToPageAtIndex:kPageLeftIndex animated:animated];
                    break;
                    
                case NSOrderedDescending: // scroll to date following current date
                    self.scrollingToDate = YES;
                    [self movePageAtIndex:kPageLeftIndex toIndex:kPageRightIndex];
                    [self updatePageDates];
                    [self scrollToPageAtIndex:kPageRightIndex animated:animated];
                    break;
                    
                case NSOrderedSame:
                    // do nothing
                    break;
            }
        }
    } else {
        DDLogWarn(@"Attempted to scroll to nil date");
    }
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
    CGRect visibleBounds = CGRectMake(self.bounds.origin.x - self.contentOffset.x + index * self.contentSize.width / 3.0f,
                                      self.bounds.origin.y,
                                      self.bounds.size.width,
                                      self.bounds.size.height);
    
    [self.pageViewDataSource infiniteDateView:self preparePage:self.pages[kPageCenterIndex]];
    [self scrollRectToVisible:visibleBounds animated:YES];
}


#pragma mark - Page Control


- (NSInteger)indexOfPageWithDate:(NSDate*)date
{
    for (NSInteger i = 0; i < self.pages.count; i++) {
        ECDatePage* page = self.pages[i];
        if ([self.calendar isDate:date equalToDate:page.date toUnitGranularity:self.calendarUnit]) {
            return i;
        }
    }
    
    return kPageNotFoundIndex;
}

- (ECDatePage*)getPageView
{
    if (self.pageViewDataSource) {
        DDLogDebug(@"Requesting page view from data source");
        return [self.pageViewDataSource pageViewForInfiniteDateView:self];
    } else {
        return [[ECDatePage alloc] initWithFrame:self.bounds];
    }
}

- (void)refreshPages
{
    if (self.date) {
        DDLogDebug(@"Refreshing pages");
        for (NSInteger i = 0; i <= kPageRightIndex; i++) {
            [self refreshPageAtIndex:i];
        }
    }
}

- (void)refreshPageAtIndex:(NSInteger)index
{
    DDLogDebug(@"Refreshing page at index %lu", (long)index);
    [self.pageViewDataSource infiniteDateView:self preparePage:self.pages[index]];
}

- (void)clearPages
{
    for (UIView* pageView in self.pages) {
        [pageView removeFromSuperview];
    }
    
    self.pages = nil;
}


#pragma mark - Delegate

- (void)informDelegateDateChangedFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    DDLogDebug(@"Informing delegate date changed from %@ to %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:fromDate], [[ECLogFormatter logMessageDateFormatter] stringFromDate:toDate]);
    if ([self.pageViewDelegate respondsToSelector:@selector(infiniteDateView:dateChangedFrom:to:)]) {
        [self.pageViewDelegate infiniteDateView:self dateChangedFrom:fromDate to:toDate];
    }
}

- (void)informDelegateVisiblePageChangedTo:(ECDatePage*)page
{
    DDLogDebug(@"Informing delgate visible page changed to page with date %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:page.date]);
    if ([self.pageViewDelegate respondsToSelector:@selector(infiniteDateView:didChangeVisiblePage:)]) {
        [self.pageViewDelegate infiniteDateView:self didChangeVisiblePage:page];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.scrollingToDate) {
        [self refreshPageAtIndex:kPageLeftIndex];
        [self refreshPageAtIndex:kPageRightIndex];
        self.scrollingToDate = NO;
    }
}

@end
