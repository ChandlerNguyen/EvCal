//
//  ECEventTextPropertyCell.m
//  EvCal
//
//  Created by Tom on 7/4/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEventTextPropertyCell.h"
#import "UIView+ECAdditions.h"
@interface ECEventTextPropertyCell() <UITextFieldDelegate>

@property (nonatomic, readwrite) BOOL propertyNameVisible;
@property (nonatomic, weak) IBOutlet UILabel* propertyNameLabel;
@property (nonatomic, weak) IBOutlet UITextField* propertyValueTextField;

@end

@implementation ECEventTextPropertyCell

#pragma mark - Properties & Lifecycle

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.clipsToBounds = YES;
    self.propertyValueTextField.delegate = self;
    [self updatePropertyNameLabelVisibilityForString:self.propertyValue animated:NO];
}

- (void)setEditingProperty:(BOOL)editingProperty
{
    BOOL oldEditing = _editingProperty;
    _editingProperty = editingProperty;
   
    if (!oldEditing && editingProperty) {
        [self.propertyValueTextField becomeFirstResponder];
        
        [self informDelegatePropertyCellBeganEditing];
    } else if (oldEditing && !editingProperty) {
        [self.propertyValueTextField resignFirstResponder];
        
        [self informDelegatePropertyCellEndedEditing];
    }
}

- (NSString*)propertyValue
{
    return self.propertyValueTextField.text;
}

- (void)setPropertyValue:(NSString *)propertyValue
{
    self.propertyValueTextField.text = propertyValue;
    
    [self updatePropertyNameLabelVisibilityForString:propertyValue animated:YES];
}

- (NSString*)propertyName
{
    return self.propertyNameLabel.text;
}

- (void)setPropertyName:(NSString *)propertyName
{
    self.propertyNameLabel.text = propertyName;
}

- (UILabel*)propertyNameLabel
{
    if (!_propertyNameLabel) {
        _propertyNameLabel = [self addLabel];
    }
    
    return _propertyNameLabel;
}

@synthesize color = _color;
- (void)setColor:(UIColor*)color
{
    _color = color;
    self.propertyNameLabel.textColor = color;
}

- (UIColor*)color
{
    if (!_color) {
        _color = [UIColor darkTextColor];
        self.propertyNameLabel.textColor = _color;
    }
    
    return _color;
}


#pragma mark - Property name label animations

static CGFloat kPropertyNameLabelAnimationDuration = 0.3f;
- (void)updatePropertyNameLabelVisibilityForString:(NSString*)newValue animated:(BOOL)animated
{
    if (!newValue || [newValue isEqualToString:@""]) {
        if (animated) {
            [self hidePropertyNameLabel:animated];
        }
    } else if (![newValue isEqualToString:@""]){
        if (animated) {
            [self showPropertyNameLabel:animated];
        }
    }
}

- (void)hidePropertyNameLabel:(BOOL)animated
{
    self.propertyNameVisible = NO;
    [self informDelegatePropertyNameWillHide];
    
    if (animated) {
        [UIView animateWithDuration:kPropertyNameLabelAnimationDuration animations:^{
            self.propertyNameLabel.alpha = 0.0f;
        }];
    } else {
        self.propertyNameLabel.alpha = 0.0f;
    }
}

- (void)showPropertyNameLabel:(BOOL)animated
{
    self.propertyNameVisible = YES;
    [self informDelegatePropertyNameWillShow];
    
    if (animated) {
        [UIView animateWithDuration:kPropertyNameLabelAnimationDuration animations:^{
            self.propertyNameLabel.alpha = 1.0f;
        }];
    } else {
        self.propertyNameLabel.alpha = 1.0f;
    }
}


#pragma mark - Property field delegate

- (void)informDelegatePropertyCellBeganEditing
{
    if ([self.propertyCellDelegate respondsToSelector:@selector(propertyCellDidBeginEditing:)]) {
        [self.propertyCellDelegate propertyCellDidBeginEditing:self];
    }
}

- (void)informDelegatePropertyCellEndedEditing
{
    if ([self.propertyCellDelegate respondsToSelector:@selector(propertyCellDidEndEditing:)]) {
        [self.propertyCellDelegate propertyCellDidEndEditing:self];
    }
}

- (void)informDelegatePropertyNameWillHide
{
    if ([self.propertyCellDelegate respondsToSelector:@selector(propertyCellWillHidePropertyName:)]) {
        [self.propertyCellDelegate propertyCellWillHidePropertyName:self];
    }
}

- (void)informDelegatePropertyNameWillShow
{
    if ([self.propertyCellDelegate respondsToSelector:@selector(propertyCellWillShowPropertyName:)]) {
        [self.propertyCellDelegate propertyCellWillShowPropertyName:self];
    }
}

- (BOOL)getShouldChangePropertyValue:(NSString*)newValue
{
    if ([self.propertyCellDelegate respondsToSelector:@selector(propertyCell:shouldChangePropertyValue:)]) {
        return [self.propertyCellDelegate propertyCell:self shouldChangePropertyValue:newValue];
    } else {
        return YES;
    }
}


#pragma mark - Text Element

- (void)didBeginEditing
{
    [self showPropertyNameLabel:YES];
    self.editingProperty = YES;
}

- (void)didEndEditingWithText:(NSString*)text
{
    [self updatePropertyNameLabelVisibilityForString:text animated:YES];
    self.editingProperty = NO;
}

- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* newValue = [self.propertyValue stringByReplacingCharactersInRange:range withString:string];
    BOOL shouldChangeCharacters = [self getShouldChangePropertyValue:newValue];
    if (shouldChangeCharacters) {
        [self updatePropertyNameLabelVisibilityForString:newValue animated:YES];
    }
    
    return shouldChangeCharacters;
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self didBeginEditing];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self didEndEditingWithText:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [self shouldChangeCharactersInRange:range replacementString:string];
}

@end
