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

// EvCal Classes
#import "ECEditEventViewController.h"
#import "ECEventStoreProxy.h"
#import "ECDatePickerCell.h"

@interface ECEditEventViewController() <UIActionSheetDelegate>

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;

// Navigation Elements
@property (nonatomic, weak) UIBarButtonItem* saveButton;

// Event Data Fields
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextField* locationTextField;

@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UIDatePicker* startDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (nonatomic, weak) IBOutlet UIDatePicker* endDatePicker;

@property (nonatomic, weak) UITextView* notesView;

@end

@implementation ECEditEventViewController

#pragma mark - Lifecycle and Properties

- (void)viewDidLoad
{
    [self setupNavigationBar];
    [self synchronizeFields];
}

- (void)setupNavigationBar
{
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.saveButton = saveButton;
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
    self.event.title = self.titleTextField.text;
    self.event.location = self.locationTextField.text;
    self.event.startDate = self.startDatePicker.date;
    self.event.endDate = self.endDatePicker.date;
    self.event.notes = self.notesView.text;
}

- (void)synchronizeFields
{
    self.titleTextField.text = self.event.title;
    self.locationTextField.text = self.event.location;
    self.startDatePicker.date = [self startDateForEvent:self.event];
    self.endDatePicker.date = [self endDateForEvent:self.event];
    self.notesView.text = self.event.notes;
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


#pragma mark - UITableView Delegate and Datasource

#define DEFAULT_ROW_HEIGHT              44.0f
#define EXPANDED_DATE_PICKER_ROW_HEIGHT 214.0f

#define START_DATE_PICKER_ROW           2
#define END_DATE_PICKER_ROW             3

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == START_DATE_PICKER_ROW || indexPath.row == END_DATE_PICKER_ROW) {
        if ([indexPath isEqual:self.selectedIndexPath]) {
            return EXPANDED_DATE_PICKER_ROW_HEIGHT;
        }
    }
    
    return DEFAULT_ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

@end
