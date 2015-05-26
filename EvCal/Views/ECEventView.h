//
//  ECEventView.h
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class EKEvent;
#import <UIKit/UIKit.h>

#define EC_EVENT_VIEW_MINIMUM_HEIGHT    12.0f

@interface ECEventView : UIView

//------------------------------------------------------------------------------
// @name Changing events
//------------------------------------------------------------------------------

/**
 *  The event represented by the event view
 */
@property (nonatomic, strong) EKEvent* event;

/**
 *  ECEventView's default init method.
 *
 *  @param event The EKEvent to be represented by the event view.
 *
 *  @return A newly created event view with its properties set according to the
 *          given event.
 */
- (instancetype)initWithEvent:(EKEvent*)event;


//------------------------------------------------------------------------------
// @name Comparing Event Views
//------------------------------------------------------------------------------

/**
 *  Compares the receiver to another event view first using their start dates
 *  and then their end dates.
 *
 *  @param other The other event view to compare against
 *
 *  @return NSOrderedAscending - if the receiver's start date is prior to the
 *          operands or the start dates are identical and the receiver's end 
 *          date is prior to the other event view's.
 *          NSOrderedDescending - if the receiver's start date is after the
 *          other event view's or the start dates are identical and the
 *          receiver's end date is after the other event view's.
 *          NSOrderedSame - if the start and end dates of the receiver and
 *          other event view are identical.
 */
- (NSComparisonResult)compare:(ECEventView*)other;

//------------------------------------------------------------------------------
// @name Calculating vertical position and height
//------------------------------------------------------------------------------

/**
 *  Calculates the apropriate height for the event view based on event view's
 *  duration and the size of the rect it is being displayed within on the date
 *  described.
 *
 *  If only a portion of the event falls on the same day at the date parameter 
 *  event view will return the height for the corresponding portion.
 * 
 *  @param rect The rect within which the event view should determine its 
 *              height. Rect should have a positive height.
 *  @param date The date with which event view should calculate its relative 
 *              height.
 *  @return The positive height for the event view or zero if the height could
 *          not be determined.
 */
- (CGFloat)heightInRect:(CGRect)rect forDate:(NSDate*)date;

/**
 *  Calculates the appropriate vertical position for the event view based on the
 *  start date of the event view's event and the height and y origin of the rect
 *  it is being displayed within.
 *
 *  @param rect The rect within which the event view should determine its
 *              vertical position.
 *  @param date The date with which event view should calculate its relative
 *              vertical position.
 *
 *  @return The absolute vertical position of the event view within the given
 *          rect or the maximum y value of the rect if the view's event starts
 *          after the given date.
 */
- (CGFloat)verticalPositionInRect:(CGRect)rect forDate:(NSDate*)date;

@end
