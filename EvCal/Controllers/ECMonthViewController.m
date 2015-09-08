//
//  ECMonthViewController.m
//  EvCal
//
//  Created by Tom on 9/8/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECMonthViewController.h"
#import "ECMonthView.h"

@interface ECMonthViewController()

@property (nonatomic, weak) ECMonthView* monthView;
@property (nonatomic, weak) ECMonthView* nextMonthView;

@end

@implementation ECMonthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDate* date = [NSDate date];
    NSDate* nextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:date options:0];
    ECMonthView* monthView = [[ECMonthView alloc] initWithDate:date];
    ECMonthView* nextMonthView = [[ECMonthView alloc] initWithDate:nextMonth];
    
    [self.view addSubview:monthView];
    [self.view addSubview:nextMonthView];
    
    self.monthView = monthView;
    self.nextMonthView = nextMonthView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self layoutMonthViews];
}

- (void)layoutMonthViews
{
    CGFloat horizontalGutterHeight = self.view.bounds.size.height / 20;
    CGFloat monthViewHeight = horizontalGutterHeight * 8;
    CGFloat verticalGutterWidth = self.view.bounds.size.width / 9;
    CGFloat monthViewWidth = verticalGutterWidth * 7;
    
    CGRect monthViewFrame = CGRectMake(self.view.bounds.origin.x + verticalGutterWidth,
                                       self.view.bounds.origin.y + horizontalGutterHeight,
                                       monthViewWidth,
                                       monthViewHeight);
    self.monthView.frame = monthViewFrame;
    
    CGRect nextMonthViewFrame = CGRectMake(monthViewFrame.origin.x,
                                           CGRectGetMaxY(monthViewFrame) + horizontalGutterHeight,
                                           monthViewWidth,
                                           monthViewHeight);
    self.nextMonthView.frame = nextMonthViewFrame;
}

@end
