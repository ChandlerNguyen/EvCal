//
//  ECEventView.h
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class EKEvent;
@class ECEventView;
#import <UIKit/UIKit.h>

@protocol ECEventViewDelegate <NSObject>

@optional

/**
 *  Informs the delegate that the event view received a tap gesture.
 *
 *  @param eventView     The event view that was tapped.
 *  @param tapRecognizer The tap gesture recognizer that fired the event.
 */
- (void)eventView:(ECEventView*)eventView wasTapped:(UITapGestureRecognizer*)tapRecognizer;

/**
 *  Informs the delegate that the event view fired a long press gesture 
 *  recognizer and began dragging.
 *
 *  @param eventView      The event view being dragged.
 *  @param dragRecognizer The gesture recognizer that fired the dragging.
 */
- (void)eventView:(ECEventView*)eventView didBeginDragging:(UILongPressGestureRecognizer*)dragRecognizer;

/**
 *  Informs the delegate that the event view was dragged.
 *
 *  @param eventView      The event view being dragged.
 *  @param dragRecognizer The gesture recognizer responsible for the dragging.
 */
- (void)eventView:(ECEventView*)eventView didDrag:(UILongPressGestureRecognizer*)dragRecognizer;

/**
 *  Informs the delegate that the event view ended dragging.
 *
 *  @param eventView      The event view that was dragged.
 *  @param dragRecognizer The gesture recognizer responsible for the dragging.
 */
- (void)eventView:(ECEventView*)eventView didEndDragging:(UILongPressGestureRecognizer*)dragRecognizer;

@end

@interface ECEventView : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The event represented by the event view
@property (nonatomic, strong) EKEvent* event;

// The event view's delegate for receiving drag events
@property (nonatomic, weak) id<ECEventViewDelegate> eventViewDelegate;


//------------------------------------------------------------------------------
// @name Changing events
//------------------------------------------------------------------------------

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

@end
