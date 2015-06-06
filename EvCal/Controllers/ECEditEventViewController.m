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

@interface ECEditEventViewController() <UIActionSheetDelegate>

@property (nonatomic, strong) NSDateFormatter* dateFormatter;

// Navigation Elements
@property (nonatomic, weak) UIBarButtonItem* saveButton;
@property (nonatomic, weak) UIBarButtonItem* cancelButton;

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
    [self addObserverToDatePickers];
}

- (void)setupNavigationBar
{
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.saveButton = saveButton;
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.cancelButton = cancelButton;
}

- (void)addObserverToDatePickers
{
    [self.startDatePicker addTarget:self action:@selector(updateStartDateLabel:) forControlEvents:UIControlEventValueChanged];
    [self.endDatePicker addTarget:self action:@selector(updateEndDateLabel:) forControlEvents:UIControlEventValueChanged];
}

- (NSDateFormatter*)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j:mm MMMM d, YYYY" options:0 locale:[NSLocale currentLocale]];
    }
    
    return _dateFormatter;
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
    [self updateStartDateLabel:self.startDatePicker];
    self.endDatePicker.date = [self endDateForEvent:self.event];
    [self updateEndDateLabel:self.endDatePicker];
    self.notesView.text = self.event.notes;
}

- (NSDate*)startDateForEvent:(EKEvent*)event
{
    if (event) {
        return event.startDate;
    } else {
        return [[NSDate date] beginningOfHour];
    }
}

- (NSDate*)endDateForEvent:(EKEvent*)event
{
    if (event) {
        return event.endDate;
    } else {
        return [[NSDate date] endOfHour];
    }
}

- (void)updateStartDateLabel:(UIDatePicker*)sender
{
    self.startDateLabel.text = [self.dateFormatter stringFromDate:sender.date];
}

- (void)updateEndDateLabel:(UIDatePicker*)sender
{
    self.endDateLabel.text = [self.dateFormatter stringFromDate:sender.date];
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

- (void)cancelButtonTapped:(UIBarButtonItem*)sender
{
    [self.delegate editEventViewControllerDidCancel:self];
}

- (IBAction)deleteButtonTapped:(UIButton *)sender {
    if (self.event.recurrenceRules.count > 0) {
        [self presentDeleteSpanActionSheet];
    } else {
        [self presentDeleteActionSheet];
    }
}

@end
