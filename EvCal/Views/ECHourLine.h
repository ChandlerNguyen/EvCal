//
//  ECHourLine.h
//  EvCal
//
//  Created by Tom on 5/28/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECHourLine : UIView

// The hour displayed by the hour line (24 hour format)
@property (nonatomic) NSInteger hour;

// The distance from the hour line's left origin that the actual line drawing
// should begin. Default is 100
@property (nonatomic) CGFloat hourLineInset;

//------------------------------------------------------------------------------
// @name Creating Hour Lines
//------------------------------------------------------------------------------

/**
 *  DESIGNATED INITIALIZER
 *  Creates a new hour line object with its hour already set.
 *
 *  @param hour The hour with which to initialize the hour line
 *
 *  @return A newly created hour line view with its hour set to the given value
 */
- (instancetype)initWithHour:(NSInteger)hour;

@end
