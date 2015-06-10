//
//  ECDayViewController.h
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDayViewController : UIViewController

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date currently displayed by the controller. Should be set before presenting
// the controller and then managed internally by the controller.
@property (nonatomic, strong) NSDate* displayDate;

@end
