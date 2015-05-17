//
//  UIView+ECAdditions.m
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "UIView+ECAdditions.h"

@implementation UIView (ECAdditions)

- (UILabel*)addLabel
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    [self addSubview:label];
    
    return label;
}

@end
