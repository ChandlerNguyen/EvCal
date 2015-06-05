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
@property (nonatomic, weak) UIBarButtonItem* deleteButton;

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
}

- (void)deleteEvent:(EKSpan)span
{
    [[ECEventStoreProxy sharedInstance] removeEvent:self.event span:span];
}

#pragma mark - Presenting Alert Views

#define EKSPAN_THIS_EVENT_BUTTON_KEY        @"EKSpanThisEvent"
#define EKSPAN_FUTURE_EVENTS_BUTTON_KEY     @"EKSpanFutureEvents"

- (void)presentSaveSpanActionSheet
{
    UIActionSheet* saveSpanActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"EditEvent.ActionSheet.This is a repeating event", @"The event being saved is repeating")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"EditEvent.ActionSheet.Cancel", @"Cancel saving event")
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"EditEvent.ActionSheet.Save for this event only", @"Save changes only for the selected occurrence of the event"),
                                                                              NSLocalizedString(@"EditEvent.ActionSheet.Save for future events", @"Save changes for all future occurrences of the event"), nil];
    [saveSpanActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
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
    
    [self.delegate editEventViewControllerDidSave:self];
}

- (void)cancelButtonTapped:(UIBarButtonItem*)sender
{
    [self.delegate editEventViewControllerDidCancel:self];
}

@end
