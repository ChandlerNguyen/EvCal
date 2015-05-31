//
//  ECDateViewAccessoryView.h
//  EvCal
//
//  Created by Tom on 5/31/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDateViewAccessoryView : UIView

@property (nonatomic, strong) UIColor* calendarColor;
@property (nonatomic) NSInteger eventCount;

- (instancetype)initWithColor:(UIColor*)color eventCount:(NSInteger)eventCount;

@end
