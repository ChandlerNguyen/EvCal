//
//  UIColor+ECAdditions.m
//  EvCal
//
//  Created by Tom on 6/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "UIColor+ECAdditions.h"

#import <EDColor/EDColor.h>

@implementation UIColor (ECAdditions)

#define TEXT_LIGHTNESS_OFFSET   -40.0f
+ (UIColor*)textColorForCGColor:(CGColorRef)cgColor
{
    UIColor* baseColor = [UIColor colorWithCGColor:cgColor];
    
    return [baseColor offsetWithLightness:TEXT_LIGHTNESS_OFFSET a:0.0f b:0.0f alpha:0.0f];
}

+ (UIColor*)eventViewBackgroundColorForCGColor:(CGColorRef)cgColor
{
    UIColor* baseColor = [UIColor colorWithCGColor:cgColor];
    
    return [baseColor offsetWithLightness:5.0f a:0.0 b:0.0 alpha:-0.25f];
}

@end
