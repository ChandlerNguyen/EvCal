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

@interface ECSingleDayView : ECDatePage

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The day views current list of event views
@property (nonatomic, strong, readonly) NSArray* eventViews;

// The scroll view contained by the day view
@property (nonatomic, weak, readonly) UIScrollView* dayScrollView;

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

//------------------------------------------------------------------------------
// @name Auto Scrolling
//------------------------------------------------------------------------------

/**
 *  Scrolls the day view to a rect containing the vertical position of the
 *  current time relative to its display date.
 *
 *  @param animated Determines whether the scroll will be animated.
 */
- (void)scrollToCurrentTime:(BOOL)animated;

@end
