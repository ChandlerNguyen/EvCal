//
//  NSArray+ECTesting.h
//  EvCal
//
//  Created by Tom on 5/19/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ECTesting)

/**
 *  Returns true if the recevier has the same elements as the other array, even
 *  if those elements are in a different order.
 *
 *  @param other The array with which to compare the receiver
 *
 *  @return YES if the receiver has the same elements, NO otherwise
 */
- (BOOL)hasSameElements:(NSArray*)other;

@end
