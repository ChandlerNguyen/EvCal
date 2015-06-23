//
//  ECInfiniteDatePagingView.h
//  EvCal
//
//  Created by Tom on 6/18/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECInfiniteDatePagingView;

//------------------------------------------------------------------------------
// @name ECInfiniteDatePagingViewDataSource
//------------------------------------------------------------------------------
@protocol ECInfiniteDatePagingViewDataSource <NSObject>
@required

/**
 *  Requests the page view for the given date view. The page view's class will
 *  be used to create other page views for scroller. It is not necessary to
 *  prepare the view before returning it.
 *
 *  @param idv The infinite date paging view making the request.
 *
 *  @return THe view to be displayed by the infinite date paging view.
 */
- (UIView*)pageViewForInfiniteDateView:(ECInfiniteDatePagingView*)idv;

/**
 *  Passes a page view to the data source allowing it to be updated before it is
 *  presented to the user with the given date. This method will often be called 
 *  during scrolling; it is important to keep the preparations efficient for the
 *  app to remain responsive.
 *
 *  @param idv  The infinite date paging view making the request
 *  @param page The page to be prepared for display
 *  @param date The date the given page represents
 */
- (void)infiniteDateView:(ECInfiniteDatePagingView*)idv preparePage:(UIView*)page forDate:(NSDate*)date;

@end

//------------------------------------------------------------------------------
// @name ECInfiniteDatePagingViewDelegate
//------------------------------------------------------------------------------
@protocol ECInfiniteDatePagingViewDelegate <NSObject>
@optional

/**
 *  Informs the delegate that the infinite paging view has updated its displayed
 *  date.
 *
 *  @param idv      The infinite date paging view which changed dates.
 *  @param fromDate The previous display date of the paging view.
 *  @param toDate   The new display date of the paging view.
 */
- (void)infiniteDateView:(ECInfiniteDatePagingView*)idv dateChangedFrom:(NSDate*)fromDate to:(NSDate*)toDate;

@end

@interface ECInfiniteDatePagingView : UIScrollView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date currently displayed by the infinite date paging view.
@property (nonatomic, strong, readonly) NSDate* date;

// The calendar unit representing the dates displayed by pages. This unit
// combined with the pageDateDelta determine how dates are added and subtracted
// during scrolling.
@property (nonatomic) NSCalendarUnit calendarUnit; // default is NSCalendarUnitDay
@property (nonatomic) NSInteger pageDateDelta; // default is 1

// The currently visible page which represents the given date
@property (nonatomic, weak, readonly) UIView* visiblePageView;

// The data source for page views
@property (nonatomic, weak) id<ECInfiniteDatePagingViewDataSource> pageViewDataSource;

// The delegate for receiving date change notifications
@property (nonatomic, weak) id<ECInfiniteDatePagingViewDelegate> pageViewDelegate;


//------------------------------------------------------------------------------
// @name Creating Views
//------------------------------------------------------------------------------

- (instancetype)initWithFrame:(CGRect)frame date:(NSDate*)date;

//------------------------------------------------------------------------------
// @name Updating display
//------------------------------------------------------------------------------

/**
 *  Instructs the date view to update the pages it is currently displaying. This
 *  will result in multiple calls to the data source.
 */
- (void)refreshPages;

/**
 *  Scrolls the page view to a page view representing the given date.
 *
 *  @param date     The date to which to scroll.
 *  @param animated Determines whether the scroll will be animated.
 */
- (void)scrollToDate:(NSDate*)date animated:(BOOL)animated;

@end
