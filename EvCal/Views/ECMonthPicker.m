//
//  ECMonthPicker.m
//  EvCal
//
//  Created by Tom on 9/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECMonthPicker.h"
@interface ECMonthPicker() <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView* monthViewContainer;

@property (nonatomic, strong) NSMutableArray* monthViewPages;

@end

@implementation ECMonthPicker

const static NSInteger kMonthViewPageCount =    3;

- (UIScrollView*)monthViewContainer
{
    if (!_monthViewContainer) {
        UIScrollView* monthViewContainer = [[UIScrollView alloc] init];
        
        monthViewContainer.delegate = self;
        monthViewContainer.pagingEnabled = YES;
        
        _monthViewContainer = monthViewContainer;
        [self addSubview:monthViewContainer];
    }
    
    return _monthViewContainer;
}

- (NSMutableArray*)monthViewPages
{
    if (!_monthViewPages) {
        _monthViewPages = [self createMonthViewPages];
    }
    
    return _monthViewPages;
}

- (NSMutableArray*)createMonthViewPages
{
    NSMutableArray* monthViewPages = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < kMonthViewPageCount; i++) {
        UIView* monthViewPage = [[UIView alloc] init];
        
    }
    
    return monthViewPages;
}

@end
