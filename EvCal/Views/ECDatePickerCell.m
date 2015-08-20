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

@property (nonatomic, weak) IBOutlet UIDatePicker* datePicker;

@property (nonatomic, strong) NSDateFormatter* dateFormatter;

@end

@implementation ECDatePickerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.datePicker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (NSDateFormatter*)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        _dateFormatter.dateFormat = [self dateFormatForDatePickerMode:self.datePickerMode];
    }
    
    return _dateFormatter;
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    self.datePicker.datePickerMode = datePickerMode;
    self.dateFormatter.dateFormat = [self dateFormatForDatePickerMode:datePickerMode];
    [self updateDateLabel:self.datePicker];
}

- (UIDatePickerMode)datePickerMode
{
    return self.datePicker.datePickerMode;
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
    self.dateLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
}

- (NSString*)dateFormatForDatePickerMode:(UIDatePickerMode)datePickerMode
{
    switch (datePickerMode) {
        case UIDatePickerModeDateAndTime:
            return [NSDateFormatter dateFormatFromTemplate:@"j:mm MMMM d, YYYY" options:0 locale:[NSLocale autoupdatingCurrentLocale]];
        
        case UIDatePickerModeDate:
            return [NSDateFormatter dateFormatFromTemplate:@"MMMM d, YYYY" options:0 locale:[NSLocale autoupdatingCurrentLocale]];
            
        case UIDatePickerModeCountDownTimer:
        case UIDatePickerModeTime:
            DDLogWarn(@"Date picker cell mode is invalid value");
            return @"";
    }
}

- (void)pickerValueChanged:(UIDatePicker*)datePicker
{
    [self updateDateLabel:datePicker];
    
    if ([self.pickerDelegate respondsToSelector:@selector(datePickerCell:didChangeDate:)]) {
        [self.pickerDelegate datePickerCell:self didChangeDate:datePicker.date];
    }
}

@end
