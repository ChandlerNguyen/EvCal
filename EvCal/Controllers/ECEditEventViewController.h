//
//  ECEditEventViewController.h
//  EvCal
//
//  Created by Tom on 6/2/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class EKEvent;
@class ECEditEventViewController;

//------------------------------------------------------------------------------
// @name Delegate methods
//------------------------------------------------------------------------------
@protocol ECEditEventViewControllerDelegate <NSObject>

/**
 *  Tells the receiver that the view controller cancelled editing without saving
 *
 *  @param controller The controller in which editing was cancelled
 */
- (void)editEventViewControllerDidCancel:(ECEditEventViewController*)controller;

/**
 *  Tells the receiver that the view controller saved changes to the event
 *
 *  @param controller THe controller in which changes were saved
 */
- (void)editEventViewControllerDidSave:(ECEditEventViewController*)controller;

/**
 *  Tells the receiver that the controller deleted the event it was editing
 *
 *  @param controller The controller in which the event was deleted
 */
- (void)editEventViewControllerDidDelete:(ECEditEventViewController*)controller;

@end

#import <UIKit/UIKit.h>

#define EC_EDIT_EVENT_VIEW_CONTROLLER_STORYBOARD_ID @"ECEditEventViewController"

@interface ECEditEventViewController : UITableViewController

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The event being edited by the controller, leave nil to create a new event
@property (nonatomic, strong) EKEvent* event;

// The start date for the event, if an event is set this value will be ignored
@property (nonatomic, strong) NSDate* startDate;
// The end date for the event, if an event is set this value will be ignored
@property (nonatomic, strong) NSDate* endDate;

// The delegate that receives messages from edit event view controller
@property (nonatomic, weak) id<ECEditEventViewControllerDelegate> delegate;

@end
