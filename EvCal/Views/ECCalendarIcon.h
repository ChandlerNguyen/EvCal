//
//  ECCalendarIcon.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECCalendarIcon : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The color of the calendar represented by the accessory view
@property (nonatomic, strong) UIColor* calendarColor;

//------------------------------------------------------------------------------
// @name Initializing
//------------------------------------------------------------------------------

/**
 *  DESIGNATED INITIALIZER
 *
 *  @param color      The color of the calendar represented by the accessory 
 *                    view
 *  @return A newly created accessory view with the given color and event count
 */
- (instancetype)initWithColor:(UIColor*)color;

@end
