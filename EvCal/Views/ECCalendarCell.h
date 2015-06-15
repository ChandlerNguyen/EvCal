//
//  ECCalendarCell.h
//  EvCal
//
//  Created by Tom on 6/15/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EKCalendar;

@interface ECCalendarCell : UITableViewCell

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The calendar represented by the cell
@property (nonatomic, strong) EKCalendar* calendar;

@end
