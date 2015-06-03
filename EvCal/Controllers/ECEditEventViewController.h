//
//  ECEditEventViewController.h
//  EvCal
//
//  Created by Tom on 6/2/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

@class EKEvent;
@class ECEditEventViewController;
@protocol ECEditEventViewControllerDelegate <NSObject>

- (void)editEventViewControllerDidCancel:(ECEditEventViewController*)controller;
- (void)editEventViewControllerDidSave:(ECEditEventViewController*)controller;

@end

#import <UIKit/UIKit.h>

#define EC_EDIT_EVENT_VIEW_CONTROLLER_STORYBOARD_ID @"ECEditEventViewController"

@interface ECEditEventViewController : UITableViewController

@property (nonatomic, strong) EKEvent* event;

@property (nonatomic, weak) id<ECEditEventViewControllerDelegate> delegate;

@end
