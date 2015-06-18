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
- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView*)idv preparePage:(UIView*)page forDate:(NSDate*)date;

@end

@protocol ECInfiniteHorizontalDatePagingViewDelegate <NSObject>

@optional
- (void)infiniteDateView:(ECInfiniteHorizontalDatePagingView*)idv dateChangedTo:(NSDate*)toDate from:(NSDate*)fromDate;

@end

@interface ECInfiniteHorizontalDatePagingView : UIScrollView

@property (nonatomic, strong) NSDate* date;
@property (nonatomic) NSCalendarUnit calendarUnit;
@property (nonatomic, weak) UIView* pageView;

@property (nonatomic, weak) id<ECInfiniteHorizontalDatePagingViewDataSource> pageViewDataSource;
@property (nonatomic, weak) id<ECInfiniteHorizontalDatePagingViewDelegate> pageViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame pageView:(UIView*)pageView date:(NSDate*)date;

@end
