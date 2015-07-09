//
//  ECEditEventRecurrenceEndViewController.h
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECEditEventRecurrenceEndViewController;
@protocol ECEditEventRecurrenceEndDelegate <NSObject>

@optional
/**
 *  Informs the receiver that the edit event recurrence end did select a new 
 *  recurrence end date.
 *
 *  @param vc      The view controller sending the delegate message.
 *  @param endDate The new end date for the controller.
 */
- (void)viewController:(nonnull ECEditEventRecurrenceEndViewController*)vc didSelectRecurrenceEndDate:(nullable NSDate*)endDate;

@end

@interface ECEditEventRecurrenceEndViewController : UITableViewController

// The view controller's recurrence end. A value of nil represents indefinite
// repeating.
@property (nonatomic, strong) NSDate* __nullable recurrenceEndDate;

@property (nonatomic, weak) id<ECEditEventRecurrenceEndDelegate> __nullable recurrenceEndDelegate;

@end
