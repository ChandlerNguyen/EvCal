//
//  ECDateView.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDateView : UIView

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, getter=isSelectedDate, readonly) BOOL selectedDate;
@property (nonatomic, getter=isTodaysDate) BOOL todaysDate;

@property (nonatomic, strong) NSArray* accessoryViews;

- (void)setSelectedDate:(BOOL)selectedDate animated:(BOOL)animated;

@end
