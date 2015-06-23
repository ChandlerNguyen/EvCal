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

/**
 *  Provides the layout with the date within which the event views will be 
 *  displayed.
 *
 *  @param layout       The layout object making the request
 *  @param eventViews   The event views being displayed
 *
 *  @return An NSDate object representing the day within which the event views
 *          will be displayed.
 */
- (NSDate*)layout:(ECDayViewEventsLayout*)layout displayDateForEventViews:(NSArray*)eventViews;

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

//------------------------------------------------------------------------------
// @name Calculating vertical position and height
//------------------------------------------------------------------------------

/**
 *  Calculates the apropriate height for an event with the given start and end 
 *  date within the given rect on the given displayed date.
 *
 *  If only a portion of the event falls on the same day at the date parameter
 *  event view will return the height for the corresponding portion.
 *
 *  @param startDate    The start date of the event.
 *  @param endDate      The end date of the event.
 *  @param displayDate  The date with which event view should calculate its relative
 *                      height.
 *  @param bounds       The rect within which the event view should determine
 *                      its height. Rect should have a positive height.
 *  @return The positive height for the event view or zero if the height could
 *          not be determined (such as if the event is all day).
 */
- (CGFloat)heightOfEventWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate displayDate:(NSDate*)displayDate bounds:(CGRect)bounds;

/**
 *  Calculates the appropriate vertical position for a date relative to the
 *  day of the display date and the height and y origin of the bounds.
 *
 *  @param date         The date for which to calculate vertical position.
 *  @param displayDate  The date relative to which vertical position should be
 *                      calculated.
 *  @param bounds       The rect within which the event view should determine
 *                      its vertical position.
 *
 *  @return The absolute vertical position of the date within the given
 *          rect or the maximum y value of the rect if the date follows
 *          after the day of the display date. 
 */
- (CGFloat)verticalPositionForDate:(NSDate*)date relativeToDate:(NSDate*)displayDate bounds:(CGRect)rect;

@end
