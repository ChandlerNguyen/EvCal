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
#import "ECRecurrenceRule.h"
#import "ECAlarm.h"

#import "ECDatePickerCell.h"
#import "ECCalendarCell.h"
#import "ECEventTextPropertyCell.h"
#import "ECRecurrenceRuleCell.h"
#import "ECAlarmCell.h"

#import "ECEditEventCalendarViewController.h"
#import "ECEditEventRecurrenceEndViewController.h"

@interface ECEditEventViewController() <ECDatePickerCellDelegate, ECEditEventCalendarViewControllerDelegate, ECAlarmCellDelegate, ECRecurrenceRuleCellDelegate, ECEditEventRecurrenceEndDelegate, ECEventTextPropertyCellDelegate, UIActionSheetDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;

// Navigation Elements
@property (nonatomic, weak) UIBarButtonItem* saveButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* deleteButton;

// Event Title and Location
@property (nonatomic, weak) IBOutlet ECEventTextPropertyCell *titleCell;
@property (nonatomic, weak) IBOutlet ECEventTextPropertyCell *locationCell;

// Event Calendar
@property (nonatomic, weak) IBOutlet ECCalendarCell* calendarCell;

// Event Start and End dates
@property (nonatomic, weak) IBOutlet ECDatePickerCell* startDatePickerCell;
@property (nonatomic, weak) IBOutlet ECDatePickerCell* endDatePickerCell;
@property (nonatomic, weak) IBOutlet UISwitch *allDaySwitch;

// Event Recurrence rules
@property (nonatomic, strong) ECRecurrenceRule* recurrenceRule;
@property (nonatomic, strong) ECAlarm* alarm;
@property (nonatomic, weak) IBOutlet ECAlarmCell* alarmCell;
@property (nonatomic, weak) IBOutlet ECRecurrenceRuleCell* recurrenceRuleCell;
@property (nonatomic, weak) IBOutlet UILabel* recurrenceEndLabel;
@property (nonatomic, strong) NSDate* recurrenceEndDate;

// Notes
@property (nonatomic, weak) IBOutlet UITextView* notesView;

@end

@implementation ECEditEventViewController

#pragma mark - Lifecycle and Properties

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.selectedIndexPath = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self synchronizeFields];
    [self setupTextPropertyCells];
    [self setupAlarmCell];
    
    self.navigationController.toolbarHidden = NO;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.startDatePickerCell.pickerDelegate = self;
    self.endDatePickerCell.pickerDelegate = self;
    self.recurrenceRuleCell.recurrenceRuleDelegate = self;
    self.notesView.delegate = self;
    [self.allDaySwitch addTarget:self action:@selector(allDaySwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
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

- (void)setupAlarmCell
{
    self.alarmCell.alarmDelegate = self;
    self.alarmCell.maximumDate = self.startDate;

    EKAlarm* eventAlarm = [self.event.alarms firstObject];
    if (!eventAlarm.absoluteDate) {
        self.alarmCell.defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:-1 toDate:self.startDate options:0];
    }
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
    [self synchronizeEventTitleAndLocation];
    [self synchronizeEventDates];
    [self synchronizeEventCalendarAndNotes];
    [self synchronizeEventRecurrenceRule];
    [self synchronizeEventAlarm];
}

- (void)synchronizeEventTitleAndLocation
{
    self.event.title = self.titleCell.propertyValue;
    self.event.location = self.locationCell.propertyValue;
}

- (void)synchronizeEventDates
{
    self.event.allDay = self.allDaySwitch.isOn;
    self.event.startDate = self.startDatePickerCell.date;
    self.event.endDate = self.endDatePickerCell.date;
}

- (void)synchronizeEventCalendarAndNotes
{
    self.event.calendar = self.calendarCell.calendar;
    self.event.notes = self.notesView.text;
}

- (void)synchronizeEventRecurrenceRule
{
    if (self.recurrenceEndDate) {
        self.recurrenceRule.rule.recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithEndDate:self.recurrenceEndDate];
    }
    
    if (self.recurrenceRule.type == ECRecurrenceRuleTypeNone) {
        self.event.recurrenceRules = nil;
    } else {
        self.event.recurrenceRules = @[self.recurrenceRule.rule];
    }
}

- (void)synchronizeEventAlarm
{
    if (self.alarm.type == ECAlarmTypeNone) {
        self.event.alarms = nil;
    } else {
        self.event.alarms = @[self.alarm.ekAlarm];
    }
}

- (void)synchronizeFields
{
    if (!self.event) {
        self.deleteButton.enabled = NO;
    }

    [self synchronizeTitleAndLocationSectionFields];
    [self synchronizeDateSectionFields];
    [self synchronizeCalendarAndNotesSectionFields];
    [self synchronizeRecurrenceRule];
    [self synchronizeAlarm];
}

- (void)synchronizeTitleAndLocationSectionFields
{
    self.titleCell.propertyValue = self.event.title;
    self.locationCell.propertyValue = self.event.location;
}

- (void)synchronizeDateSectionFields
{
    self.startDatePickerCell.date = [self startDateForEvent:self.event];
    self.endDatePickerCell.date = [self endDateForEvent:self.event];
    self.allDaySwitch.on = self.event.isAllDay;
    [self updateDatePickersForAllDayStatus:self.allDaySwitch.on];
}

- (void)synchronizeCalendarAndNotesSectionFields
{
    self.calendarCell.calendar = (self.event) ? self.event.calendar : [ECEventStoreProxy sharedInstance].defaultCalendar;
    self.notesView.text = self.event.notes;
}

- (void)synchronizeRecurrenceRule
{
    self.recurrenceRule = [[ECRecurrenceRule alloc] initWithRecurrenceRule:[self.event.recurrenceRules firstObject]];
    self.recurrenceRuleCell.recurrenceRule = self.recurrenceRule;
    self.recurrenceEndDate = self.recurrenceRule.rule.recurrenceEnd.endDate;
    self.recurrenceEndLabel.text = [self recurrenceEndTextForRecurrenceEndDate:self.recurrenceEndDate];
}

- (void)synchronizeAlarm
{
    self.alarm = [[ECAlarm alloc] initWithEKAlarm:[self.event.alarms firstObject]];
    self.alarmCell.alarm = self.alarm;
}

- (NSString*)recurrenceEndTextForRecurrenceEndDate:(NSDate*)endDate
{
    if (!endDate) {
        return NSLocalizedString(@"ECEditEventViewController.RecurrenceEnd.Never", @"The event never stops repeating");
    } else {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMM d, YYYY" options:0 locale:[NSLocale autoupdatingCurrentLocale]];
        return [formatter stringFromDate:endDate];
    }
}

- (void)updateDatePickersForAllDayStatus:(BOOL)allDay
{
    UIDatePickerMode datePickerMode = (allDay) ? UIDatePickerModeDate : UIDatePickerModeDateAndTime;
    self.startDatePickerCell.datePickerMode = datePickerMode;
    self.endDatePickerCell.datePickerMode = datePickerMode;
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


#pragma mark - Commiting event changes

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

- (IBAction)deleteButtonTapped:(UIBarButtonItem *)sender {
    if (self.event.recurrenceRules.count > 0) {
        [self presentDeleteSpanActionSheet];
    } else {
        [self presentDeleteActionSheet];
    }
}

- (void)allDaySwitchValueChanged:(UISwitch*)sender
{
    [self updateDatePickersForAllDayStatus:sender.isOn];
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


#pragma mark - ECAlarmCell Delegate

- (void)alarmCell:(ECAlarmCell *)cell didSelectAlarm:(ECAlarm *)alarm
{
    self.alarm = alarm;
}

#pragma mark - ECRecurrenceRuleCell Delegate

- (void)recurrenceCell:(ECRecurrenceRuleCell *)cell didSelectRecurrenceRule:(ECRecurrenceRule *)rule
{
    self.recurrenceRule = rule;
}

#pragma mark - ECEditEventRecurrenceEnd Delegate

- (void)viewController:(nonnull ECEditEventRecurrenceEndViewController *)vc didSelectRecurrenceEndDate:(nullable NSDate *)endDate
{
    self.recurrenceEndDate = endDate;
    self.recurrenceEndLabel.text = [self recurrenceEndTextForRecurrenceEndDate:endDate];
}


#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.selectedIndexPath = [NSIndexPath indexPathForRow:kNotesCellRow inSection:kNotesSection];
    [self updateCellHeights];
}


#pragma mark - UITableView Delegate and Datasource
#pragma mark Cell Heights
const static CGFloat kDefaultCellHeight =               44.0f;
const static CGFloat kCollapsedPickerCellHeight =       52.0f;
const static CGFloat kTextPropertyHiddenNameHeight =    33.0f;
const static CGFloat kTextPropertyVisibleNameHeight =   52.0f;
const static CGFloat kExpandedPickerCellHeight =        244.0f;
const static CGFloat kAllDayCellHeight =                44.0f;

const static NSInteger kTitleLocationCalendarSection =  0;
const static NSInteger kDateAndAllDaySection =          1;
const static NSInteger kRecurrenceSection =             2;
const static NSInteger kNotesSection =                  3;

const static NSInteger kTitleCellRow =                  0;
const static NSInteger kCalendarCellRow =               2;
const static NSInteger kRecurrenceEndCellRow =          2;
const static NSInteger kAllDayCellRow =                 2;
const static NSInteger kNotesCellRow =                  0;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kTitleLocationCalendarSection:
            return [self heightForCellInTitleLocationSectionAtIndexPath:indexPath];
            
        case kDateAndAllDaySection:
            return [self heightForCellInDateAndAllDaySectionAtIndexPath:indexPath];
            
        case kRecurrenceSection:
            return [self heightForCellInRecurrenceSectionAtIndexPath:indexPath];
            
        case kNotesSection:
            return [self heightForCellInNotesSectionAtIndexPath:indexPath];
            
        default:
            return 0.0f;
    }
}

- (CGFloat)heightForCellInTitleLocationSectionAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == kTitleCellRow) {
        return self.titleCell.propertyNameVisible ? kTextPropertyVisibleNameHeight : kTextPropertyHiddenNameHeight;
    } else if (indexPath.row == kCalendarCellRow) {
        return kDefaultCellHeight;
    } else {
        return self.locationCell.propertyNameVisible ? kTextPropertyVisibleNameHeight : kTextPropertyHiddenNameHeight;
    }
}

- (CGFloat)heightForCellInDateAndAllDaySectionAtIndexPath:(NSIndexPath*)indexPath
{
    // all day cell
    if (indexPath.row == kAllDayCellRow) {
        return kAllDayCellHeight;
    } else {
        // if the date picker cell is highlighted it should be taller
        if ([indexPath isEqual:self.selectedIndexPath]) {
            return kExpandedPickerCellHeight;
        } else {
            return kCollapsedPickerCellHeight;
        }
    }
}

- (CGFloat)heightForCellInRecurrenceSectionAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == kRecurrenceEndCellRow) {
        if (self.recurrenceRule.type == ECRecurrenceRuleTypeNone) {
            return 0.0f;
        } else {
            return kDefaultCellHeight;
        }
    } else {
        if ([indexPath isEqual:self.selectedIndexPath]) {
            return kExpandedPickerCellHeight;
        } else {
            return kCollapsedPickerCellHeight;
        }
    }
}

- (CGFloat)heightForCellInNotesSectionAtIndexPath:(NSIndexPath*)indexPath
{
    return kExpandedPickerCellHeight;
}

- (void)updateCellHeights
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark Cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // short circuiting the || operator
    if (indexPath.section != kTitleLocationCalendarSection ||
        indexPath.row == kCalendarCellRow) {
        self.titleCell.editingProperty = NO;
        self.locationCell.editingProperty = NO;
    }
    
    if (indexPath.section != kNotesSection) {
        [self.notesView resignFirstResponder];
    }
    
    if ([self.selectedIndexPath isEqual:indexPath]) {
        self.selectedIndexPath = nil;
    } else {
        self.selectedIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updateCellHeights];
    [self scrollTableViewToRectIfNecessary];
}

- (void)scrollTableViewToRectIfNecessary
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    CGFloat cellFrameMaxY = CGRectGetMaxY(cell.frame) + kCollapsedPickerCellHeight; // add a little cushion at the bottom
    CGFloat tableViewMaxY = self.tableView.contentOffset.y + self.tableView.bounds.size.height;
    
    if (cellFrameMaxY > tableViewMaxY) {
        CGPoint contentOffset = CGPointMake(0, cellFrameMaxY - self.tableView.bounds.size.height);
        [self.tableView setContentOffset:contentOffset animated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"calendar"]) {
        ECEditEventCalendarViewController* eceecvc = (ECEditEventCalendarViewController*)segue.destinationViewController;
        eceecvc.calendar = self.calendarCell.calendar;
        eceecvc.calendarDelegate = self;
    } else if ([segue.identifier isEqualToString:@"recurrenceEnd"]) {
        ECEditEventRecurrenceEndViewController* eceerevc = (ECEditEventRecurrenceEndViewController*)segue.destinationViewController;
        eceerevc.recurrenceEndDelegate = self;
        eceerevc.recurrenceEndDate = self.recurrenceEndDate;
    }
}

@end
