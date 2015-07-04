//
//  ECEventTextPropertyCell.h
//  EvCal
//
//  Created by Tom on 7/4/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECEventTextPropertyCell;

//------------------------------------------------------------------------------
// @name ECEventTextPropertyCell delegate
//------------------------------------------------------------------------------

@protocol ECEventTextPropertyCellDelegate <NSObject>
@optional
/**
 *  Informs the receiver that the property cell entered editing mode.
 *
 *  @param cell The cell that has entered editing mode
 */
- (void)propertyCellDidBeginEditing:(ECEventTextPropertyCell*)cell;

/**
 *  Informs the receiver that the property Cell finished editing.
 *
 *  @param cell The cell that has ended editing.
 */
- (void)propertyCellDidEndEditing:(ECEventTextPropertyCell*)cell;

/**
 *  Requests confirmation that the property value should be changed to the new 
 *  value. This method is an entry point for changing state based on the value
 *  of the property.
 *
 *  @param cell    The cell whose value is going to be changed.
 *  @param newValue The new string that will replace the current property value.
 *
 *  @return YES if the changes should be made or NO otherwise
 */
- (BOOL)propertyCell:(ECEventTextPropertyCell*)cell shouldChangePropertyValue:(NSString*)newValue; // default is YES

/**
 *  Informs the delegate that the cell will hide its property name.
 *
 *  @param cell The cell that is hiding its property name.
 */
- (void)propertyCellWillHidePropertyName:(ECEventTextPropertyCell*)cell;

/**
 *  Informs the delegate that the cell will show its property name.
 *
 *  @param cell The cell that is showing its property name.
 */
- (void)propertyCellWillShowPropertyName:(ECEventTextPropertyCell*)cell;

@end

@interface ECEventTextPropertyCell : UITableViewCell

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The name of the property being edited by the cell.
@property (nonatomic, strong) NSString* propertyName;

// The current value of the property being edited by the cell.
@property (nonatomic, strong) NSString* propertyValue;

// Determines whether the property is currently editing. Set to yes to begin
// editing behavior.
@property (nonatomic, getter=isEditingProperty) BOOL editingProperty;

// Determines whether the property name is visible
@property (nonatomic, readonly) BOOL propertyNameVisible;

// The delegate that should receive the above protocol messages.
@property (nonatomic, weak) id<ECEventTextPropertyCellDelegate> propertyCellDelegate;

// The color of the displayed property name.
@property (nonatomic, strong) UIColor* color; // default is [UIColor darkTextColor]


@end
