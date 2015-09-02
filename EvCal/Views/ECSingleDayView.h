//
//  ECSingleDayView.h
//  EvCal
//
//  Created by Tom on 6/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDatePage.h"
#import <UIKit/UIKit.h>
@class ECEventView;
@class ECSingleDayView;

@protocol ECSingleDayViewDelegate <NSObject>

@optional

/**
 *  Informs the receiver that the single day view's visible date was changed.
 *
 *  @param singleDayView The single day view that had its visible date changed.
 *  @param date          The new value for the visible date.
 */
- (void)singleDayView:(ECSingleDayView*)singleDayView visibleDateChanged:(NSDate*)date;

/**
 *  Informs the receiver that an event view within the sender's list was 
 *  selected.
 *
 *  @param eventView The event view that was selected.
 */
- (void)eventViewWasSelected:(ECEventView*)eventView;

/**
 *  Informs the receiver that an event view within the sender's list was dragged
 *  to a new start date. The receiver of this message is responsible for
 *  comitting or undoing the change to the user event represented by the event 
 *  view.
 *
 *  @param eventView The event view that was dragged.
 *  @param date      The date to which the event view was dragged.
 */
- (void)eventView:(ECEventView*)eventView wasDraggedToDate:(NSDate*)date;

@end

@interface ECSingleDayView : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The day views current list of event views
@property (nonatomic, strong, readonly) NSArray* eventViews;

// The date being displayed by the single day view.
@property (nonatomic, strong) NSDate* date;

// The delegate for event view changes
@property (nonatomic, weak) id<ECSingleDayViewDelegate> singleDayViewDelegate;

//------------------------------------------------------------------------------
// @name Manging Event Views
//------------------------------------------------------------------------------

/**
 *  Add an event view to the receiver. The view will be placed according to its
 *  start and end date time.
 *
 *  @param eventView The event view to be added.
 */
- (void)addEventView:(ECEventView*)eventView;

/**
 *  Add several event views to the receiver simultaneously.
 *
 *  @param eventViews The event views to be added.
 */
- (void)addEventViews:(NSArray*)eventViews;

/**
 *  Remove the given event from the receiver.
 *
 *  @param eventView The event view to be removed.
 */
- (void)removeEventView:(ECEventView*)eventView;

/**
 *  Remove several event views from the receiver simultaneously.
 *
 *  @param eventViews The event views to be removed.
 */
- (void)removeEventViews:(NSArray*)eventViews;

/**
 *  Remove all event views from the receiver.
 */
- (void)clearEventViews;

/**
 *  Invalidate current event views layout and refresh them on next layout cycle.
 */
- (void)refreshEventViewLayout;

//------------------------------------------------------------------------------
// @name Current time
//------------------------------------------------------------------------------

/**
 *  Scrolls the day view to a rect containing the vertical position of the
 *  current time relative to its display date.
 *
 *  @param animated Determines whether the scroll will be animated.
 */
- (void)scrollToCurrentTime:(BOOL)animated;

/**
 *  Scrolls the day view to a rect containing the given time.
 *
 *  @param time     The time to which to scroll
 *  @param animated Determines whether the scroll will be animated.
 */
- (void)scrollToTime:(NSDate*)time animated:(BOOL)animated;

/**
 *  Causes the receiver to update its current time line (if one is visible)
 */
- (void)updateCurrentTime;

@end
