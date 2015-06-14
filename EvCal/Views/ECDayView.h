//
//  ECDayView.h
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class EKEvent;
@class ECEventView;
#import <UIKit/UIKit.h>

@interface ECDayView : UIScrollView

//------------------------------------------------------------------------------
// @name Date and Time
//------------------------------------------------------------------------------

// The date currently being displayed by the day view.
// Changes to this date will not update which event views are displayed, but may
// result in their layout being changed.
@property (nonatomic, strong) NSDate* displayDate;

//------------------------------------------------------------------------------
// @name Manging Event Views
//------------------------------------------------------------------------------

// The day views current list of event views
@property (nonatomic, readonly) NSArray* eventViews;

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

//------------------------------------------------------------------------------
// @name Auto Scrolling
//------------------------------------------------------------------------------

- (void)scrollToCurrentTime:(BOOL)animated;

@end
