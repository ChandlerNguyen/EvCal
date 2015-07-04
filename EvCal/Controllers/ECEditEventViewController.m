//
//  ECEditEventViewController.m
//  EvCal
//
//  Created by Tom on 6/2/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

// iOS Frameworks
@import EventKit;

// Helpers
#import "NSDate+CupertinoYankee.h"
#import "UIColor+ECAdditions.h"

// EvCal Classes
#import "ECEditEventViewController.h"
#import "ECEventStoreProxy.h"
#import "ECDatePickerCell.h"
#import "ECCalendarCell.h"
#import "ECEditEventCalendarViewController.h"
#import "ECEventTextPropertyCell.h"

@interface ECEditEventViewController() <ECDatePickerCellDelegate, ECEditEventCalendarViewControllerDelegate, ECEventTextPropertyCellDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;

// Navigation Elements
@property (nonatomic, weak) UIBarButtonItem* saveButton;

// Event Data Fields
@property (weak, nonatomic) IBOutlet ECEventTextPropertyCell *titleCell;
@property (weak, nonatomic) IBOutlet ECEventTextPropertyCell *locationCell;

@property (nonatomic, weak) IBOutlet ECDatePickerCell* startDatePickerCell;
@property (nonatomic, weak) IBOutlet ECDatePickerCell* endDatePickerCell;

@property (nonatomic, weak) IBOutlet ECCalendarCell* calendarCell;

@property (nonatomic, weak) UITextView* notesView;

@end

@implementation ECEditEventViewController

#pragma mark - Lifecycle and Properties

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self synchronizeFields];
    [self setupTextPropertyCells];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.startDatePickerCell.pickerDelegate = self;
    self.endDatePickerCell.pickerDelegate = self;
}

- (void)setupNavigationBar
{
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.saveButton = saveButton;
    self.saveButton.enabled = [self eventIsValidWithTitle:self.event.title startDate:self.event.startDate endDate:self.event.endDate];
}

- (void)setupTextPropertyCells
{
    self.titleCell.color = [UIColor ecPurpleColor];
    self.locationCell.color = [UIColor ecPurpleColor];
    
    self.titleCell.propertyCellDelegate = self;
    self.locationCell.propertyCellDelegate = self;
}

- (NSDate*)startDate
{
    if (!_startDate) {
        _startDate = [[NSDate date] beginningOfHour];
    }
    
    return _startDate;
}

- (NSDate*)endDate
{
    if (!_endDate) {
        _endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:1 toDate:self.startDate options:0];
    }
    
    return _endDate;
}


#pragma mark - Synchronizing event and fields

- (void)synchronizeEvent
{
    self.event.title = self.titleCell.propertyValue;
    self.event.location = self.locationCell.propertyValue;
    self.event.startDate = self.startDatePickerCell.date;
    self.event.endDate = self.endDatePickerCell.date;
    self.event.calendar = self.calendarCell.calendar;
    self.event.notes = self.notesView.text;
}

- (void)synchronizeFields
{
    self.titleCell.propertyValue = self.event.title;
    self.locationCell.propertyValue = self.event.location;
    self.startDatePickerCell.date = [self startDateForEvent:self.event];
    self.endDatePickerCell.date = [self endDateForEvent:self.event];
    self.calendarCell.calendar = (self.event) ? self.event.calendar : [ECEventStoreProxy sharedInstance].defaultCalendar;
    self.notesView.text = self.event.notes;
}

- (BOOL)eventIsValidWithTitle:(NSString*)title startDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    if (!title || [title isEqualToString:@""]) {
        return NO;
    }
    
    if (!startDate || !endDate || [startDate compare:endDate] != NSOrderedAscending) {
        return NO;
    }
    
    return YES;
}

- (NSDate*)startDateForEvent:(EKEvent*)event
{
    if (event) {
        return event.startDate;
    } else {
        return self.startDate;
    }
}

- (NSDate*)endDateForEvent:(EKEvent*)event
{
    if (event) {
        return event.endDate;
    } else {
        return self.endDate;
    }
}

- (void)saveEventChanges:(EKSpan)span
{
    [self synchronizeEvent];
    
    [[ECEventStoreProxy sharedInstance] saveEvent:self.event span:span];
    
    [self.delegate editEventViewControllerDidSave:self];
}

- (void)deleteEvent:(EKSpan)span
{
    [[ECEventStoreProxy sharedInstance] removeEvent:self.event span:span];
    
    [self.delegate editEventViewControllerDidDelete:self];
}

#pragma mark - Presenting Alert Views

#define SAVE_SPAN_ACTION_SHEET_TAG          101
#define DELETE_EVENT_ACTION_SHEET_TAG       102
#define DELETE_SPAN_ACTION_SHEET_TAG        103

- (void)presentSaveSpanActionSheet
{
    UIActionSheet* saveSpanActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"EditEvent.SaveSpan.ActionSheet.This is a repeating event", @"The event being saved is repeating")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"EditEvent.SaveSpan.ActionSheet.Cancel", @"Cancel saving event")
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"EditEvent.SaveSpan.ActionSheet.Save for this event only", @"Save changes only for the selected occurrence of the event"),
                                                                              NSLocalizedString(@"EditEvent.SaveSpan.ActionSheet.Save for future events", @"Save changes for all future occurrences of the event"), nil];
    saveSpanActionSheet.tag = SAVE_SPAN_ACTION_SHEET_TAG;
    [saveSpanActionSheet showInView:self.view];
}

- (void)presentDeleteActionSheet
{
    UIActionSheet* deleteActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"EditEvent.DeleteEvent.ActionSheet.You cannot undo this action", @"The user cannot undo deleting an event")
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"EditEvent.DeleteEvent.ActionSheet.Cancel", @"Cancel deleting event") destructiveButtonTitle:NSLocalizedString(@"EditEvent.DeleteEvent.ActionSheet.Delete Event", @"Delete the event")
                                                          otherButtonTitles:nil];
    
    deleteActionSheet.tag = DELETE_EVENT_ACTION_SHEET_TAG;
    [deleteActionSheet showInView:self.view];
}

- (void)presentDeleteSpanActionSheet
{
    UIActionSheet* deleteSpanActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"EditEvent.DeleteSpan.ActionSheet.This is a repeating event", @"The event being deleted is repeating")
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"EditEvent.DeleteSpan.ActionSheet.Cancel", @"Cancel deleting event")
                                                         destructiveButtonTitle:nil
                                                              otherButtonTitles:NSLocalizedString(@"EditEvent.DeleteSpan.ActionSheet.Delete this event only", @"Delete only the given occurrence of the event"),
                                                                                NSLocalizedString(@"EditEvent.DeleteSpan,ActionSheet.Delete future events", @"Delete all future occurrences of the event"), nil];
    
    deleteSpanActionSheet.tag = DELETE_SPAN_ACTION_SHEET_TAG;
    [deleteSpanActionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case SAVE_SPAN_ACTION_SHEET_TAG:
            [self saveSpanActionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
            break;
            
        case DELETE_EVENT_ACTION_SHEET_TAG:
            [self deleteEventActionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
            break;
            
        case DELETE_SPAN_ACTION_SHEET_TAG:
            [self deleteSpanActionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
            break;
            
        default:
            break;
    }
}

- (void)saveSpanActionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"EditEvent.SaveSpan.ActionSheet.Save for this event only", @"Save changes only for the selected occurrence of the event")]) {
        [self saveEventChanges:EKSpanThisEvent];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"EditEvent.SaveSpan.ActionSheet.Save for future events", @"Save changes for all future occurrences of the event")]) {
        [self saveEventChanges:EKSpanFutureEvents];
    }
}

- (void)deleteEventActionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self deleteEvent:EKSpanThisEvent];
    }
}

- (void)deleteSpanActionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"EditEvent.DeleteSpan.ActionSheet.Delete this event only", @"Delete only the given occurrence of the event")]) {
        [self deleteEvent:EKSpanThisEvent];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"EditEvent.DeleteSpan,ActionSheet.Delete future events", @"Delete all future occurrences of the event")]) {
        [self deleteEvent:EKSpanFutureEvents];
    }
}

#pragma mark - UI Events

- (void)saveButtonTapped:(UIBarButtonItem*)sender
{
    if (!self.event) {
        self.event = [[ECEventStoreProxy sharedInstance] createEvent];
        [self saveEventChanges:EKSpanThisEvent];
    } else {
        if (self.event.recurrenceRules.count > 0) {
            [self presentSaveSpanActionSheet];
        } else {
            [self saveEventChanges:EKSpanThisEvent];
        }
    }
}

- (IBAction)deleteButtonTapped:(UIButton *)sender {
    if (self.event.recurrenceRules.count > 0) {
        [self presentDeleteSpanActionSheet];
    } else {
        [self presentDeleteActionSheet];
    }
}


#pragma mark - ECDatePicker Delegate

- (void)datePickerCell:(ECDatePickerCell *)cell didChangeDate:(NSDate *)date
{
    self.saveButton.enabled = [self eventIsValidWithTitle:self.titleCell.propertyValue startDate:self.startDatePickerCell.date endDate:self.endDatePickerCell.date];
}


#pragma mark - ECTextPropertyCell delegate

- (BOOL)propertyCell:(ECEventTextPropertyCell *)cell shouldChangePropertyValue:(NSString *)newValue
{
    if ([cell isEqual:self.titleCell]) {
        if ([self eventIsValidWithTitle:newValue startDate:self.startDatePickerCell.date endDate:self.endDatePickerCell.date]) {
            self.saveButton.enabled = YES;
        } else {
            self.saveButton.enabled = NO;
        }
    }
    
    return YES;
}

- (void)propertyCellWillShowPropertyName:(ECEventTextPropertyCell *)cell
{
    [self updateCellHeights];
}

- (void)propertyCellWillHidePropertyName:(ECEventTextPropertyCell *)cell
{
    [self updateCellHeights];
}

- (void)propertyCellDidBeginEditing:(ECEventTextPropertyCell *)cell
{
    self.selectedIndexPath = [self.tableView indexPathForCell:cell];
    [self updateCellHeights];
}


#pragma mark - ECEditEventCalendarViewController Delegate

- (void)viewController:(ECEditEventCalendarViewController *)vc didSelectCalendar:(EKCalendar *)calendar
{
    self.calendarCell.calendar = calendar;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableView Delegate and Datasource

const static CGFloat kHeaderHeight =                    33.0f;
const static CGFloat kDefaultRowHeight =                44.0f;
const static CGFloat kTextPropertyHiddenNameHeight =    33.0f;
const static CGFloat kTextPropertyVisibleNameHeight =   52.0f;
const static CGFloat kExpandedDatePickerHeight =        214.0f;

const static NSInteger kTitleLocationSection =          0;
const static NSInteger kDateAndRepeatSection =          1;
const static NSInteger kCalendarAndRecurrenceSection =  2;

const static NSInteger kTitleCellRow =                  0;
//const static NSInteger kLocationCellRow =               1;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kTitleLocationSection:
            return [self heightForCellInTitleLocationSectionAtIndexPath:indexPath];
            break;
        case kDateAndRepeatSection:
            if ([indexPath isEqual:self.selectedIndexPath]) {
                return kExpandedDatePickerHeight;
            } else {
                return kDefaultRowHeight;
            }
        case kCalendarAndRecurrenceSection:
            return kDefaultRowHeight;
            
        default:
            return kDefaultRowHeight;
            break;
    }
}

- (CGFloat)heightForCellInTitleLocationSectionAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == kTitleCellRow) {
        return self.titleCell.propertyNameVisible ? kTextPropertyVisibleNameHeight : kTextPropertyHiddenNameHeight;
    } else {
        return self.locationCell.propertyNameVisible ? kTextPropertyVisibleNameHeight : kTextPropertyHiddenNameHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != kTitleLocationSection) {
        self.titleCell.editingProperty = NO;
        self.locationCell.editingProperty = NO;
    }
    
    if ([self.selectedIndexPath isEqual:indexPath]) {
        self.selectedIndexPath = nil;
    } else {
        self.selectedIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)updateCellHeights
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"calendar"]) {
        ECEditEventCalendarViewController* eceecvc = (ECEditEventCalendarViewController*)segue.destinationViewController;
        eceecvc.calendar = self.calendarCell.calendar;
        eceecvc.calendarDelegate = self;
    }
}

@end
