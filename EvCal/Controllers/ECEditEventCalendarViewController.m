//
//  ECEditEventCalendarViewController.m
//  EvCal
//
//  Created by Tom on 6/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEventStoreProxy.h"
#import "ECEditEventCalendarViewController.h"
@interface ECEditEventCalendarViewController()

@property (nonatomic, strong) NSArray* calendars;

@end

@implementation ECEditEventCalendarViewController

#pragma mark - Properties and Lifecycle

- (NSArray*)calendars
{
    if (!_calendars) {
        _calendars = [ECEventStoreProxy sharedInstance].calendars;
    }
    
    return _calendars;
}

#pragma mark - UITableView Delegate and Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ECEventStoreProxy sharedInstance].calendars.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"calendarCell"];
    
    EKCalendar* calendar = self.calendars[indexPath.row];
    cell.textLabel.text = calendar.title;
    
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:[self.calendars indexOfObject:self.calendar] inSection:0]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSIndexPath* oldIndexPath = [NSIndexPath indexPathForRow:[self.calendars indexOfObject:self.calendar] inSection:0];
    if (![indexPath isEqual:oldIndexPath]) {
        self.calendar = self.calendars[indexPath.row];
        
        UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        UITableViewCell* newCell = [tableView cellForRowAtIndexPath:indexPath];
        
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

@end
