//
//  NSArray+ECTesting.m
//  EvCal
//
//  Created by Tom on 5/19/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "NSArray+ECTesting.h"

@implementation NSArray (ECTesting)

- (BOOL)hasSameElements:(NSArray *)other
{
    if (self.count != other.count) {
        return NO;
    }
 
    // create a mutable copy to avoid side effects
    NSMutableArray* mutableOther = [other mutableCopy];
    for (id elem in self) {
        if (![mutableOther containsObject:elem]) {
            return NO;
        } else {
            // removing the element ensures both arrays contain equal numbers
            // of matching objects
            [mutableOther removeObject:elem];
        }
    }
    
    return YES;
}

@end
