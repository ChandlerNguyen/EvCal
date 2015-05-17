//
//  UIView+ECAdditions.h
//  EvCal
//
//  Created by Tom on 5/17/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ECAdditions)

//------------------------------------------------------------------------------
// @name Adding Views
//------------------------------------------------------------------------------

/**
 * Adds a new UILabel to the receiver's subviews
 *
 * @return  The label just added to the receiver's subviews
 */
- (UILabel*)addLabel;

@end
