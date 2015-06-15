//
//  UIColor+ECAdditions.h
//  EvCal
//
//  Created by Tom on 6/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ECAdditions)

//------------------------------------------------------------------------------
// @name View specific colors
//------------------------------------------------------------------------------

/**
 *  Creates a new color object by lightening the given color and lowering the
 *  opacity. Used primarily for event view background colors.
 *
 *  @param cgColor The calendar color to be translated.
 *
 *  @return The newly created color object.
 */
+ (UIColor*)eventViewBackgroundColorForCGColor:(CGColorRef)cgColor;

/**
 *  Creates a new color object by darkening the given color. Used primarily for
 *  event view description text.
 *
 *  @param cgColor The calendar color to be translated.
 *
 *  @return The newly created color object.
 */
+ (UIColor*)textColorForCGColor:(CGColorRef)cgColor;

//------------------------------------------------------------------------------
// @name EvCal colors
//------------------------------------------------------------------------------

/**
 *  EvCal Purple: #6F38B0
 *
 *  @return EvCal's default purple color.
 */
+ (UIColor*)ecPurpleColor;

/**
 *  EvCal Red: #FB414A
 *
 *  @return EvCal's default red color.
 */
+ (UIColor*)ecRedColor;

/**
 *  EvCal Green: #45D336
 *
 *  @return EvCal's default green color.
 */
+ (UIColor*)ecGreenColor;

@end
