//
//  ECEditEventCalendarViewController.h
//  EvCal
//
//  Created by Tom on 6/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EKCalendar;
@class ECEditEventCalendarViewController;
@protocol ECEditEventCalendarViewControllerDelegate <NSObject>
@optional

- (void)viewController:(ECEditEventCalendarViewController*)vc didSelectCalendar:(EKCalendar*)calendar;

@end

@interface ECEditEventCalendarViewController : UITableViewController

@property (nonatomic, weak) id<ECEditEventCalendarViewControllerDelegate> calendarDelegate;

@property (nonatomic, strong) EKCalendar* calendar;

@end
