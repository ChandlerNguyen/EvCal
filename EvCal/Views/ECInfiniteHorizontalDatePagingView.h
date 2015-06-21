//
//  ECInfiniteHorizontalDatePagingView.h
//  EvCal
//
//  Created by Tom on 6/18/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECInfiniteHorizontalDatePagingView;
@protocol ECInfiniteHorizontalDatePagingViewDataSource <NSObject>
@required

- (UIView*)pageViewForInfiniteDateView:(ECInfiniteHorizontalDatePagingView*)idv;

- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView*)idv preparePage:(UIView*)page forDate:(NSDate*)date;

@end

@protocol ECInfiniteHorizontalDatePagingViewDelegate <NSObject>

@optional
- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView*)idv dateChangedFrom:(NSDate*)fromDate to:(NSDate*)toDate;

@end

@interface ECInfiniteHorizontalDatePagingView : UIScrollView

@property (nonatomic, strong, readonly) NSDate* date;
@property (nonatomic) NSCalendarUnit calendarUnit;
@property (nonatomic) NSInteger pageDateDelta;
@property (nonatomic, weak) UIView* pageView;
@property (nonatomic, weak, readonly) UIView* visiblePageView;

@property (nonatomic, weak) id<ECInfiniteHorizontalDatePagingViewDataSource> pageViewDataSource;
@property (nonatomic, weak) id<ECInfiniteHorizontalDatePagingViewDelegate> pageViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame date:(NSDate*)date;

- (void)refreshPages;

- (void)scrollToDate:(NSDate*)date animated:(BOOL)animated;

@end
