//
//  ECEventViewFactory.h
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class EKEvent;
#import "ECEventView.h"
#import <Foundation/Foundation.h>

@interface ECEventViewFactory : NSObject

//------------------------------------------------------------------------------
// @name Creating event views
//------------------------------------------------------------------------------

/**
 *  Creates a new event view for the event.
 *
 *  @param event The event with which to create a new event view.
 *
 *  @return A newly created event view with its event properties configured.
 */
+ (ECEventView*)eventViewForEvent:(EKEvent*)event;

/**
 *  Creates new event views for each of the events passed.
 *
 *  @param events The events for which to create event views.
 *
 *  @return An array of event views matching the order events were passed.
 */
+ (NSArray*)eventViewsForEvents:(NSArray*)events;

/**
 *  Reuses old event views when possible and creates new event views for the 
 *  remaining events.
 *
 *  @param events     The events for which to create event views.
 *  @param eventViews Reusable event views.
 *
 *  @return An array of event views matching the order events were passed.
 */
+ (NSArray*)eventViewsForEvents:(NSArray *)events reusingViews:(NSArray*)eventViews;

@end
