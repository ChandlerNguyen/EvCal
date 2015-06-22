//
//  ECInfiniteDatePagingView.h
//  EvCal
//
//  Created by Tom on 6/18/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECInfiniteDatePagingView;
@protocol ECInfiniteDatePagingViewDataSource <NSObject>
@required

- (UIView*)pageViewForInfiniteDateView:(ECInfiniteDatePagingView*)idv;

- (void)infiniteDateView:(ECInfiniteDatePagingView*)idv preparePage:(UIView*)page forDate:(NSDate*)date;

@end

@protocol ECInfiniteDatePagingViewDelegate <NSObject>

@optional
- (void)infiniteDateView:(ECInfiniteDatePagingView*)idv dateChangedFrom:(NSDate*)fromDate to:(NSDate*)toDate;

@end

@interface ECInfiniteDatePagingView : UIScrollView

@property (nonatomic, strong, readonly) NSDate* date;
@property (nonatomic) NSCalendarUnit calendarUnit;
@property (nonatomic) NSInteger pageDateDelta;
@property (nonatomic, weak, readonly) UIView* visiblePageView;

@property (nonatomic, weak) id<ECInfiniteDatePagingViewDataSource> pageViewDataSource;
@property (nonatomic, weak) id<ECInfiniteDatePagingViewDelegate> pageViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame date:(NSDate*)date;

- (void)refreshPages;

- (void)scrollToDate:(NSDate*)date animated:(BOOL)animated;

@end
