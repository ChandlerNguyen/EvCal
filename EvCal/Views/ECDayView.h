//
//  ECDayView.h
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class ECEventView;
#import <UIKit/UIKit.h>

@interface ECDayView : UIScrollView

- (void)addEventView:(ECEventView*)eventView;
- (void)addEventViews:(NSArray*)eventViews;
- (void)removeEventView:(ECEventView*)eventView;
- (void)removeEventViews:(NSArray*)eventViews;

@end
