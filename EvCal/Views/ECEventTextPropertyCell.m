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
    self.propertyValueTextField.delegate = self;
    [self updatePropertyNameLabelVisibilityForString:self.propertyValue animated:NO];
}

- (void)setEditingProperty:(BOOL)editingProperty
{
    BOOL oldEditing = _editingProperty;
    _editingProperty = editingProperty;
   
    if (!oldEditing && editingProperty) {
        [self.propertyValueTextField becomeFirstResponder];
        [self informDelegatePropertyFieldBeganEditing];
    } else if (oldEditing && !editingProperty) {
        [self.propertyValueTextField resignFirstResponder];
        [self informDelegatePropertyFieldEndedEditing];
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

- (UITextField*)propertyValueTextField
{
    if (!_propertyValueTextField) {
        UITextField* propertyValueTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        propertyValueTextField.placeholder = self.propertyName;
        
        [self addSubview:propertyValueTextField];
        _propertyValueTextField = propertyValueTextField;
    }
    
    return _propertyValueTextField;
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
            [UIView animateWithDuration:kPropertyNameLabelAnimationDuration animations:^{
                [self hidePropertyNameLabel];
            }];
        } else {
            [self hidePropertyNameLabel];
        }
    } else if (![newValue isEqualToString:@""]){
        if (animated) {
            [UIView animateWithDuration:kPropertyNameLabelAnimationDuration animations:^{
                [self showPropertyNameLabel];
            }];
        } else {
            [self showPropertyNameLabel];
        }
    }
}

- (void)hidePropertyNameLabel
{
    self.propertyNameLabel.alpha = 0.0f;
}

- (void)showPropertyNameLabel
{
    self.propertyNameLabel.alpha = 1.0f;
}


#pragma mark - Property field delegate

- (void)informDelegatePropertyFieldBeganEditing
{
    if ([self.propertyFieldDelegate respondsToSelector:@selector(propertyFieldDidBeginEditing:)]) {
        [self.propertyFieldDelegate propertyFieldDidBeginEditing:self];
    }
}

- (void)informDelegatePropertyFieldEndedEditing
{
    if ([self.propertyFieldDelegate respondsToSelector:@selector(propertyFieldDidEndEditing:)]) {
        [self.propertyFieldDelegate propertyFieldDidEndEditing:self];
    }
}

- (BOOL)getShouldChangePropertyValue:(NSString*)newValue
{
    if ([self.propertyFieldDelegate respondsToSelector:@selector(propertyField:shouldChangePropertyValue:)]) {
        return [self.propertyFieldDelegate propertyField:self shouldChangePropertyValue:newValue];
    } else {
        return YES;
    }
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.editingProperty = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.editingProperty = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* newValue = [self.propertyValue stringByReplacingCharactersInRange:range withString:string];
    BOOL shouldChangeCharacters = [self getShouldChangePropertyValue:newValue];
    if (shouldChangeCharacters) {
        [self updatePropertyNameLabelVisibilityForString:newValue animated:YES];
    }
    
    return shouldChangeCharacters;
}

@end
