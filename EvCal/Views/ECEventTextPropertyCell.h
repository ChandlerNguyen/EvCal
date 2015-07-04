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
 *  Informs the receiver that the property field entered editing mode.
 *
 *  @param field The field that has entered editing mode
 */
- (void)propertyFieldDidBeginEditing:(ECEventTextPropertyCell*)field;

/**
 *  Informs the receiver that the property field finished editing.
 *
 *  @param field The field that has ended editing.
 */
- (void)propertyFieldDidEndEditing:(ECEventTextPropertyCell*)field;

/**
 *  Requests confirmation that the property value should be changed to the new 
 *  value. This method is an entry point for changing state based on the value
 *  of the property.
 *
 *  @param field    The field whose value is going to be changed.
 *  @param newValue The new string that will replace the current property value.
 *
 *  @return YES if the changes should be made or NO otherwise
 */
- (BOOL)propertyField:(ECEventTextPropertyCell*)field shouldChangePropertyValue:(NSString*)newValue; // default is YES

@end

@interface ECEventTextPropertyCell : UITableViewCell

//------------------------------------------------------------------------------
// @name Properties
//------------------------------------------------------------------------------

// The name of the property being edited by the field.
@property (nonatomic, strong) NSString* propertyName;

// The current value of the property being edited by the field.
@property (nonatomic, strong) NSString* propertyValue;

// Determines whether the property is currently editing. Set to yes to begin
// editing behavior.
@property (nonatomic, getter=isEditing) BOOL editingProperty;

// The delegate that should receive the above protocol messages.
@property (nonatomic, weak) id<ECEventTextPropertyCellDelegate> propertyFieldDelegate;

// The color of the displayed property name.
@property (nonatomic, strong) UIColor* color; // default is [UIColor darkTextColor]


@end
