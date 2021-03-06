//
//  ECTimeLine.h
//  EvCal
//
//  Created by Tom on 5/28/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

const static CGFloat ECTimeLineThicknessNormal = 0.5f;
const static CGFloat ECTimeLineThicknessBold = 1.0f;
const static CGFloat ECTimeLineThicknessBlack = 2.0f;

@interface ECTimeLine : UIView

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------


// The date displayed by the hour line (24 hour format)
@property (nonatomic) NSDate* date;

// The distance from the hour line's left origin that the actual line drawing
// should begin.
@property (nonatomic, readonly) CGFloat timeLineInset; // default is 50

// if YES the time line will not display its time. The time line will still
// consider the time during layout
@property (nonatomic) BOOL timeHidden; // default is no

// The color of the time line
@property (nonatomic, strong) UIColor* color; // default is [UIColor lightGrayColor]

// The thickness of the time line's horizontal line
@property (nonatomic) CGFloat lineThickness; // default is ECTimeLineThicknessNormal;

// The format for displaying time line's date object
@property (nonatomic, strong) NSString* dateFormatTemplate; // default is "j"

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
- (instancetype)initWithDate:(NSDate*)date;

@end
