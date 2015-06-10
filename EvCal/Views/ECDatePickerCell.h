//
//  ECDatePickerCell.h
//  EvCal
//
//  Created by Tom on 6/7/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDatePickerCell : UITableViewCell

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date displayed by the cell and in its picker
@property (nonatomic, weak) NSDate* date;

@end
