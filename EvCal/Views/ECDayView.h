//
//  ECDayView.h
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
@class EKEvent;
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

/**
 *  Informs the receiver that an event displayed within the event view was 
 *  selected.
 *
 *  @param dayView The day view that is presenting the event
 *  @param event   The event that was selected
 */
- (void)dayView:(ECDayView*)dayView eventWasSelected:(EKEvent*)event;

/**
 *  Informs the receiver that an event's start date was changed within the day 
 *  view's UI. The new start date is provided, but the event has not been 
 *  changed. The receiver can decide whether to accept this change and make it 
 *  permanent.
 *
 *  @param dayView   The day view that controls the event view that was changed.
 *  @param event     The event whose start date should be changed.
 *  @param startDate The new start date for the event.
 */
- (void)dayView:(ECDayView*)dayView event:(EKEvent*)event startDateChanged:(NSDate*)startDate span:(EKSpan)span;

@end

//------------------------------------------------------------------------------
// @name ECDayView data source
//------------------------------------------------------------------------------
@protocol ECDayViewDataSource <NSObject>

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
- (NSArray*)dayView:(ECDayView*)dayView eventsForDate:(NSDate*)date;

@end

@interface ECDayView : UIView


//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date currently being displayed by the day view.
@property (nonatomic, strong) NSDate* displayDate;

// The data source for the day view's event views and content size
@property (nonatomic, weak) id<ECDayViewDataSource> dayViewDataSource;

// The delegate for the day view's scroll events
@property (nonatomic, weak) id<ECDayViewDelegate> dayViewDelegate;

// The height on screen for the day view
@property (nonatomic) CGFloat dayViewHeight; // default is 3 * bounds.size.height


//------------------------------------------------------------------------------
// @name Initialization
//------------------------------------------------------------------------------

/**
 *  Creates a new day view with the given date and frame.
 *
 *  @param frame The frame to display the day view within.
 *  @param date  The date to be dispalyed within the day view.
 *
 *  @return The newly created day view.
 */
- (instancetype)initWithFrame:(CGRect)frame displayDate:(NSDate*)date;


//------------------------------------------------------------------------------
// @name Refreshing day view
//------------------------------------------------------------------------------

/**
 *  Forces the day view to refetch and layout its event views. 
 */
- (void)refreshCalendarEvents;

/**
 *  Updates the location and visibility of the current time line.
 */
- (void)updateCurrentTime;


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
