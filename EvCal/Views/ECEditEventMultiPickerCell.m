//
//  ECEditEventMultiPickerCell.m
//  EvCal
//
//  Created by Tom on 8/15/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEditEventMultiPickerCell.h"
@interface ECEditEventMultiPickerCell()

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* infoLabel;

@property (nonatomic, weak) IBOutlet UIButton* switchPickerButton;

@property (nonatomic, weak) IBOutlet UIView* pickerContainerView;
@property (nonatomic, weak, readwrite) UIPickerView* primaryPickerView;
@property (nonatomic, weak, readwrite) UIPickerView* secondaryPickerView;

@end

@implementation ECEditEventMultiPickerCell

#pragma mark - Lifecycle and Properties

- (UIPickerView*)addPickerView
{
    UIPickerView* pickerView = [[UIPickerView alloc] init];
    
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    [self.pickerContainerView addSubview:pickerView];
    
    return pickerView;
}

- (UIPickerView*)primaryPickerView
{
    if (!_primaryPickerView) {
        _primaryPickerView = [self addPickerView];
    }
    
    return _primaryPickerView;
}

- (UIPickerView*)secondaryPickerView
{
    if (!_secondaryPickerView) {
        _secondaryPickerView = [self addPickerView];
    }
    
    return _secondaryPickerView;
}


#pragma mark - Layout




#pragma mark - UI Events

- (IBAction)switchPickerButtonTapped:(UIButton*)sender
{
    
}

#pragma mark - UIPickerView Delegate and Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}

@end
