//
//  ECEditEventCalendarViewController.h
//  EvCal
//
//  Created by Tom on 6/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EKCalendar;

@interface ECEditEventCalendarViewController : UITableViewController

@property (nonatomic, strong) EKCalendar* calendar;

@end
