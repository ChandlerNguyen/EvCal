//
//  ECEventView.h
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class EKEvent;
#import <UIKit/UIKit.h>

@interface ECEventView : UIControl

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



@end
