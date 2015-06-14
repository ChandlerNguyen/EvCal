//
//  ECEditEventCalendarViewController.m
//  EvCal
//
//  Created by Tom on 6/14/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECEventStoreProxy.h"
#import "ECEditEventCalendarViewController.h"

@implementation ECEditEventCalendarViewController

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
    
    EKCalendar* calendar = [ECEventStoreProxy sharedInstance].calendars[indexPath.row];
    cell.textLabel.text = calendar.title;
    
    return cell;
}

@end
