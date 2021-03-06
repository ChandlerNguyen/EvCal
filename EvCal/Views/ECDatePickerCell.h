//
//  ECDatePickerCell.h
//  EvCal
//
//  Created by Tom on 6/7/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECDatePickerCell;
@protocol ECDatePickerCellDelegate <NSObject>
@optional
/**
 *  Informs the receiver that the picker cell's date value changed
 *
 *  @param cell The cell whose date value has changed
 *  @param date The new date value
 */
- (void)datePickerCell:(ECDatePickerCell*)cell didChangeDate:(NSDate*)date;

@end

@interface ECDatePickerCell : UITableViewCell

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The date displayed by the cell and in its picker.
@property (nonatomic, weak) NSDate* date;

// The label displaying the cell's selected date.
@property (nonatomic, weak) IBOutlet UILabel* dateLabel;

// The cell's date picker mode.
@property (nonatomic) UIDatePickerMode datePickerMode; // default is UIDatePickerModeDateAndTime

// The delegate that receives messages from the picker cell.
@property (nonatomic, weak) id<ECDatePickerCellDelegate> pickerDelegate;

@end
