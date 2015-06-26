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

@property (nonatomic, strong) NSMutableArray* pages;
@property (nonatomic, weak) UIView* pageContainerView;

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
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}


#pragma mark Public
- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    
    if (self.pageView && !CGRectEqualToRect(oldFrame, frame)) {
        CGSize threePageContentSize = CGSizeMake(frame.size.width * 3, frame.size.height);
        [super setContentSize:threePageContentSize];
        
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
    DDLogDebug(@"Changing date from: %@ to: %@", [[ECLogFormatter logMessageDateFormatter] stringFromDate:_date], [[ECLogFormatter logMessageDateFormatter] stringFromDate:date]);
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

//CGRect movedPageFrame = CGRectMake(self.pageContainerView.bounds.origin.x + toIndex * self.contentSize.width / 3.0f,
//                                   self.pageContainerView.bounds.origin.y,
//                                   self.bounds.size.width,
//                                   self.bounds.size.height);
//movedPage.frame = movedPageFrame;

- (void)updatePageIndices
{
    ECDatePage* leftPageView = self.pages[kPageLeftIndex];
    ECDatePage* rightPageView = self.pages[kPageRightIndex];
    
    CGFloat pageWidth = self.contentSize.width / 3.0f;
    if (leftPageView.frame.origin.x < self.bounds.origin.x - pageWidth) {
        DDLogDebug(@"Left page scrolled out of container");
        [self movePageAtIndex:kPageLeftIndex toIndex:kPageRightIndex];
        self.date = self.centerPageDate;
        [self updatePageAtIndex:kPageRightIndex];
    } else if (CGRectGetMaxX(rightPageView.frame) > CGRectGetMaxX(self.bounds) + pageWidth) {
        DDLogDebug(@"Right page scrolled out of container");
        [self movePageAtIndex:kPageRightIndex toIndex:kPageLeftIndex];
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
    UIView* movedPage = self.pages[fromIndex];
    [self.pages removeObject:movedPage];
    [self.pages insertObject:movedPage atIndex:toIndex];
}

- (void)updatePageAtIndex:(NSInteger)index
{
    ECDatePage* changeDatePage = self.pages[index];
    changeDatePage.date = [self.calendar dateByAddingUnit:self.calendarUnit value:(index - kPageCenterIndex) * self.pageDateDelta toDate:self.date options:0];
    [self.pageViewDataSource infiniteDateView:self preparePage:changeDatePage];
}

- (void)updatePageDates
{
    for (NSInteger i = 0; i < self.pages.count; i++) {
        ECDatePage* page = self.pages[i];
        page.date = [self.calendar dateByAddingUnit:self.calendarUnit value:(i - kPageCenterIndex) * self.pageDateDelta toDate:self.date options:0];
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    if (date) {
        self.date = date;
        if (animated) {
            if (![self.calendar isDate:date equalToDate:self.centerPageDate toUnitGranularity:self.calendarUnit]) {
                NSComparisonResult dateOrder = [date compare:self.centerPageDate];
                switch (dateOrder) {
                    case NSOrderedAscending: // scroll to date prior to current date
                        self.scrollingToDate = YES;
                        [self movePageAtIndex:kPageRightIndex toIndex:kPageLeftIndex];
                        [self updatePageDates];
                        [self scrollToPageAtIndex:kPageLeftIndex];
                        break;
                        
                    case NSOrderedDescending: // scroll to date following current date
                        self.scrollingToDate = YES;
                        [self movePageAtIndex:kPageLeftIndex toIndex:kPageRightIndex];
                        [self updatePageDates];
                        [self scrollToPageAtIndex:kPageRightIndex];
                        break;
                        
                    case NSOrderedSame:
                        break;
                }
            }
        } else { // do not animate transition
            
        }
    } else {
        DDLogWarn(@"Attempted to scorll to nil date");
    }
}

- (void)scrollToPageAtIndex:(NSInteger)index
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
        return [self.pageViewDataSource pageViewForInfiniteDateView:self];
    } else {
        return [[ECDatePage alloc] initWithFrame:self.bounds];
    }
}

- (void)refreshPages
{
    if (self.date) {
        for (NSInteger i = 0; i <= kPageRightIndex; i++) {
            [self refreshPageAtIndex:i];
        }
    }
}

- (void)refreshPageAtIndex:(NSInteger)index
{
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
    if ([self.pageViewDelegate respondsToSelector:@selector(infiniteDateView:dateChangedFrom:to:)]) {
        [self.pageViewDelegate infiniteDateView:self dateChangedFrom:fromDate to:toDate];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.scrollingToDate) {
        [self refreshPageAtIndex:kPageLeftIndex];
        [self refreshPageAtIndex:kPageRightIndex];
    }
    self.scrollingToDate = NO;
}

@end
