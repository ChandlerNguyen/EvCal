//
//  ECDateViewFactory.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECDateView;

@interface ECDateViewFactory : NSObject

- (ECDateView*)dateViewForDate:(NSDate*)date;
- (ECDateView*)configureDateView:(ECDateView*)dateView forDate:(NSDate*)date;

@end
