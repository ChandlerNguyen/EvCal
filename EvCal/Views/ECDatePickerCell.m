//
//  ECDatePickerCell.m
//  EvCal
//
//  Created by Tom on 6/7/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECDatePickerCell.h"
#import "NSDateFormatter+ECAdditions.h"

@interface ECDatePickerCell()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* datePickerHeight;

@end

@implementation ECDatePickerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.datePicker addTarget:self action:@selector(updateDateLabel:) forControlEvents:UIControlEventValueChanged];
    [self updateDateLabel:self.datePicker];
}

#define DATE_PICKER_SELECTED_HEIGHT 162.0f
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.datePickerHeight.constant = DATE_PICKER_SELECTED_HEIGHT;
    } else {
        self.datePickerHeight.constant = 0;
    }
}

- (void)updateDateLabel:(UIDatePicker*)datePicker
{
    NSDateFormatter* dateFormatter = [NSDateFormatter ecEventDatesFormatter];
    
    self.dateLabel.text = [dateFormatter stringFromDate:datePicker.date];
}

@end
