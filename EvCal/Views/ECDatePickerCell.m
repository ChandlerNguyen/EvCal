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

@property (nonatomic, weak) IBOutlet UILabel* dateLabel;
@property (nonatomic, weak) IBOutlet UIDatePicker* datePicker;

@end

@implementation ECDatePickerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.datePicker addTarget:self action:@selector(updateDateLabel:) forControlEvents:UIControlEventValueChanged];
}

- (void)setDate:(NSDate *)date
{
    self.datePicker.date = date;
    [self updateDateLabel:self.datePicker];
}

- (NSDate*)date
{
    return self.datePicker.date;
}

- (void)updateDateLabel:(UIDatePicker*)datePicker
{
    NSDateFormatter* dateFormatter = [NSDateFormatter ecEventDatesFormatter];
    
    self.dateLabel.text = [dateFormatter stringFromDate:datePicker.date];
}

@end
