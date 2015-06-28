//
//  ECWeekdaysContainerView.h
//  EvCal
//
//  Created by Tom on 6/20/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECDatePage.h"

@interface ECWeekdaysContainerView : ECDatePage

@property (nonatomic, strong) NSDate* selectedDate;
@property (nonatomic, strong, readonly) NSArray* weekdays;
@property (nonatomic, strong, readonly) NSArray* dateViews;
/**
 *  DESIGNATED INITIALIZER
 *
 *  @param date The date to be used for initialization
 *
 *  @return The newly created weekday container
 */
- (instancetype)initWithDate:(NSDate*)date;

@end
