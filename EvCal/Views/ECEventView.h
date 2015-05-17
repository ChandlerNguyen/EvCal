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

@end
