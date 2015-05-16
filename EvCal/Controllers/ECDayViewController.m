//
//  ECDayViewController.m
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDayViewController.h"
#import "ECDayView.h"

@interface ECDayViewController ()

@property (nonatomic) UIView* dayView;

@end

@implementation ECDayViewController

- (UIView*)dayView {
    if (!_dayView) {
        _dayView = [[ECDayView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_dayView];
    }
    
    return _dayView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dayView.backgroundColor = [UIColor whiteColor];
}

@end
