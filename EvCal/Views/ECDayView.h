//
//  ECDayView.h
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
@class ECEventView;

@class ECDayView;

@protocol ECDayViewDelegate <NSObject>

@optional
/**
 *  Informs the receiver that a horizontal scroll to the given date has 
 *  occurred.
 *
 *  @param dayView The day view that was scrolled
 *  @param fromDate The day view's previous date
 *  @param toDate The day view's current date
 */
- (void)dayView:(ECDayView*)dayView didScrollFrom:(NSDate*)fromDate to:(NSDate*)toDate;

/**
 *  Informs the receiver that a vertical scroll has occurred within the day 
 *  view.
 *
 *  @param dayView The day view that was scrolled.
 */
- (void)dayViewDidScrollTime:(ECDayView*)dayView;

@end

//------------------------------------------------------------------------------
// @name ECDayView data source
//------------------------------------------------------------------------------
@protocol ECDayViewDatasource <NSObject>

@required
/**
 *  Requests an array of event view objects to be displayed by the calling day 
 *  view (which is passed as a parameter). Default is nil.
 *
 *  @param dayView          The day view making the request.
 *  @param date             The date for which to provide event views.
 *  @param reusableViews    The array of event views which can be reused.
 *
 *  @return An array of event view objects
 */
- (NSArray*)dayView:(ECDayView*)dayView eventViewsForDate:(NSDate*)date reusingViews:(NSArray*)reusableViews;

/**
 *  Requests the size of the content to be displayed within a single day. 
 *  Default is the day view bound's size.
 *
 *
 *  @param dayView The day view making the request
 *
 *  @return The size of the day view's content
 */
- (CGSize)contentSizeForDayView:(ECDayView*)dayView;

@end

@interface ECDayView : UIView


//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date currently being displayed by the day view.
@property (nonatomic, strong, readonly) NSDate* displayDate;

/**
 *  Sets the receiver's display date to the given value and can animate the
 *  changes if needed.
 *
 *  @param displayDate The value to which to set display date
 *  @param animated    Determines whether the change should be animated
 */
- (void)setDisplayDate:(NSDate *)displayDate animated:(BOOL)animated;


// The data source for the day view's event views and content size
@property (nonatomic, weak) id<ECDayViewDatasource> dayViewDataSource;

// The delegate for the day view's scroll events
@property (nonatomic, weak) id<ECDayViewDelegate> dayViewDelegate;


- (instancetype)initWithFrame:(CGRect)frame displayDate:(NSDate*)date;

//------------------------------------------------------------------------------
// @name Refreshing event views
//------------------------------------------------------------------------------

/**
 *  Forces the day view to refetch and layout its event views. 
 */
- (void)refreshCalendarEvents;


//------------------------------------------------------------------------------
// @name Auto Scrolling
//------------------------------------------------------------------------------

/**
 *  Scrolls the receiver's visible rect to a rect that contains the current
 *  time in the top half of the view. If the rect already contains the current
 *  time this method has no effect other than performing some layout math.
 *
 *  The day view's delegate will be informed of this change.
 *
 *  @param animated Determines whether the scroll action is animated.
 */
- (void)scrollToCurrentTime:(BOOL)animated;

/**
 *  Scrolls the receiver to display the given date. This results in the day view
 *  displaying a list of events for the supplied date and its properties updated
 *  to the given date.
 *
 *  The day view's delegate will be informed of this change.
 *
 *  @param date     The date to which to scroll
 *  @param animated Determines whether the scroll action is animated.
 */
- (void)scrollToDate:(NSDate*)date animated:(BOOL)animated;

@end
