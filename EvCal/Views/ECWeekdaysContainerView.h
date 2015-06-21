//
//  ECWeekdaysContainerView.h
//  EvCal
//
//  Created by Tom on 6/20/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECWeekdaysContainerView : UIView

@property (nonatomic, strong) NSDate* selectedDate;
@property (nonatomic, strong) NSArray* dateViews;

@end
