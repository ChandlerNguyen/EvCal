//
//  ECEditEventCalendarViewController.h
//  EvCal
//
//  Created by Tom on 6/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EKCalendar;

//------------------------------------------------------------------------------
// @name Calendar view controller delegate
//------------------------------------------------------------------------------
@class ECEditEventCalendarViewController;
@protocol ECEditEventCalendarViewControllerDelegate <NSObject>
@optional
/**
 *  Informs the receiver that the given view controller has selected a calendar.
 *
 *  @param vc       The view controller making the delegate call
 *  @param calendar The calendar selected within the controller
 */
- (void)viewController:(ECEditEventCalendarViewController*)vc didSelectCalendar:(EKCalendar*)calendar;

@end

@interface ECEditEventCalendarViewController : UITableViewController

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The delegate that receives messages from the view controller
@property (nonatomic, weak) id<ECEditEventCalendarViewControllerDelegate> calendarDelegate;

// The view controller's selected calendar
@property (nonatomic, strong) EKCalendar* calendar;

@end
