//
//  ECDateViewFactory.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECDateView;

@interface ECDateViewFactory : NSObject

//------------------------------------------------------------------------------
// @name Creating Date Views
//------------------------------------------------------------------------------

/**
 *  Creates a new date view object for the given date with its date set
 *  according to the value of the date parameter and the appropriate accessory 
 *  views for the given date.
 *
 *  @param date The new date view's date
 *
 *  @return A newly created date view with the given date
 */
- (ECDateView*)dateViewForDate:(NSDate*)date;

//------------------------------------------------------------------------------
// @name Updating Date Views
//------------------------------------------------------------------------------

/**
 *  Updates the given date view to reflect the given date. This includes
 *  refreshing the accessory views.
 *
 *  @param dateView The date view to be configured
 *  @param date     The date with which to configure the date view
 */
- (void)configureDateView:(ECDateView*)dateView forDate:(NSDate*)date;

@end
