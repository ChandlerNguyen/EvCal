//
//  UIColor+ECAdditions.h
//  EvCal
//
//  Created by Tom on 6/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ECAdditions)

+ (UIColor*)eventViewBackgroundColorForCGColor:(CGColorRef)cgColor;
+ (UIColor*)textColorForCGColor:(CGColorRef)cgColor;

+ (UIColor*)ecPurpleColor;
+ (UIColor*)ecRedColor;
+ (UIColor*)ecGreenColor;

@end
