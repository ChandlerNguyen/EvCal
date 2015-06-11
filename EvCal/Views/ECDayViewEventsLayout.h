//
//  ECDayViewEventsLayout.h
//  EvCal
//
//  Created by Tom on 6/11/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@import UIKit;

@class ECEventView;
@class ECDayViewEventsLayout;

//------------------------------------------------------------------------------
// @name Data Source Protocol
//------------------------------------------------------------------------------
@protocol ECDayViewEventsLayoutDataSource <NSObject>

@required
/**
 *  Provides the layout with the proper bounds within which to layout the given
 *  event views. The default value is CGRectZero.
 *
 *  @param layout     The layout object making the request.
 *  @param eventViews The event views being layed out.
 *
 *  @return A CGRect that represents the bounds within which to lay out the given
 *          event views.
 */
- (CGRect)layout:(ECDayViewEventsLayout*)layout boundsForEventViews:(NSArray*)eventViews;

/**
 *  Provides the layout with the event views to lay out. 
 *  The default value is nil;
 *
 *  @param layout The layout object making the request.
 *
 *  @return An array of event views.
 */
- (NSArray*)eventViewsForLayout:(ECDayViewEventsLayout*)layout;

@optional
/**
 *  Returns the minimum height for an event view. This value will be used 
 *  when an event view's start and end date would naturally give it a height 
 *  less than the minimum height. The value should be a non-negative integer.
 *  The default value is 22.0f.
 *
 *  @param layout The layout object making the request.
 *
 *  @return The minimum height to be used by the layout object.
 */
- (CGFloat)minimumEventHeightForLayout:(ECDayViewEventsLayout*)layout;

@end

@interface ECDayViewEventsLayout : NSObject

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The data source for providing required layout information
@property (nonatomic, weak) id<ECDayViewEventsLayoutDataSource> layoutDataSource;

//------------------------------------------------------------------------------
// @name Creating Event View frames
//------------------------------------------------------------------------------

/**
 *  Informs the layout object that its current cache of event view frames is no
 *  longer valid. This method can be called multiple times with no noticable 
 *  effect on performance.
 */
- (void)invalidateLayout;

/**
 *  Returns the correct frame for the given event view. If the event view 
 *  represents an all day event this method will always return CGRectZero.
 *
 *  @param eventView The event view for which to return a frame
 *
 *  @return A frame for the given event view according to the bounds and event
 *          views provided by the layout's data source.
 */
- (CGRect)frameForEventView:(ECEventView*)eventView;

@end
