//
//  ECEditEventRecurrenceEndViewController.m
//  EvCal
//
//  Created by Tom on 7/9/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEditEventRecurrenceEndViewController.h"
#import "ECDatePickerCell.h"
#import "MSCellAccessory.h"

@interface ECEditEventRecurrenceEndViewController () <ECDatePickerCellDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell* neverRecurrenceEndCell;
@property (nonatomic, weak) IBOutlet ECDatePickerCell* recurrenceEndDateCell;
@property (nonatomic, weak) IBOutlet UIView* recurrenceEndDateCellCheckmarkContainer;

@end

@implementation ECEditEventRecurrenceEndViewController

#pragma mark - Lifecycle and Properties

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recurrenceEndDateCell.pickerDelegate = self;
    self.recurrenceEndDateCellCheckmarkContainer.backgroundColor = [UIColor whiteColor];
    [self.recurrenceEndDateCellCheckmarkContainer addSubview:[MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIApplication sharedApplication].delegate.window.tintColor]];
    
    if (self.recurrenceEndDate) {
        self.recurrenceEndDateCell.date = self.recurrenceEndDate;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateCellAppearanceForRecurrenceEndDate:self.recurrenceEndDate];
}

- (void)updateCellAppearanceForRecurrenceEndDate:(NSDate*)recurrenceEndDate
{
    if (!recurrenceEndDate) {
        self.neverRecurrenceEndCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.recurrenceEndDateCellCheckmarkContainer.hidden = YES;
    } else {
        self.neverRecurrenceEndCell.accessoryType = UITableViewCellAccessoryNone;
        self.recurrenceEndDateCellCheckmarkContainer.hidden = NO;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


#pragma mark - Delegate 

- (void)informDelegateRecurrenceEndDateWasSelected
{
    if ([self.recurrenceEndDelegate respondsToSelector:@selector(viewController:didSelectRecurrenceEndDate:)]) {
        [self.recurrenceEndDelegate viewController:self didSelectRecurrenceEndDate:self.recurrenceEndDate];
    }
}


#pragma mark - Date picker cell delegate

- (void)datePickerCell:(ECDatePickerCell *)cell didChangeDate:(NSDate *)date
{
    self.recurrenceEndDate = date;
    [self updateCellAppearanceForRecurrenceEndDate:date];
    [self informDelegateRecurrenceEndDateWasSelected];
}

#pragma mark - Tableview delegate and datasource

const static NSInteger kRecurrenceEndDateNeverCellRow =             0;

const static CGFloat kRecurrenceEndDateNeverCellHeight =            44.0f;
const static CGFloat kRecurrenceEndDatePickerCellUnselectedHeight = 44.0f;
const static CGFloat kRecurrenceEndDatePickerCellSelectedHeight =   206.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kRecurrenceEndDateNeverCellRow) {
        return kRecurrenceEndDateNeverCellHeight;
    } else {
        if (self.recurrenceEndDate) {
            return kRecurrenceEndDatePickerCellSelectedHeight;
        } else {
            return kRecurrenceEndDatePickerCellUnselectedHeight;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[tableView indexPathForCell:self.neverRecurrenceEndCell]]) {
        self.recurrenceEndDate = nil;
    } else {
        self.recurrenceEndDate = self.recurrenceEndDateCell.date;
    }
    
    [self updateCellAppearanceForRecurrenceEndDate:self.recurrenceEndDate];
    [self informDelegateRecurrenceEndDateWasSelected];
}

@end
