//
//  TimeUnit.swift
//  Pods
//
//  Created by Tom on 9/4/15.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Large portions of this code were influenced by Matt Thompson (http://mattt.me).
// The original code can be found at https://github.com/mattt/CupertinoYankee
//

import Foundation

public class TimeUnit : NSObject {
    
// MARK: - Properties and Lifecycle
    
    /// Private static instance for static methods
    private static let sharedInstance = TimeUnit()
    
    /// The calendar to be used for date calculations
    public lazy var calendar : NSCalendar = {
       return NSCalendar.autoupdatingCurrentCalendar()
    }()
    
// MARK: - Calculate beginning of time unit
    
    /**
        Creates a new date at the first second of the same hour as the given date
    
        - parameter date: The new date for which to calculate the beginning of the hour
    
        - returns: The newly created date representing the first second of the hour
    */
    public func beginningOfHour(date:NSDate) -> NSDate {
        let components = self.calendar.components(
            ([.Year, .Month, .Day, .Hour]), fromDate: date
        )
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same hour as the given date
    
        - parameter date: The new date for which to calculate the beginning of the hour
    
        - returns: The newly created date representing the first second of the hour
    */
    static public func beginningOfHour(date:NSDate) -> NSDate {
        return sharedInstance.beginningOfHour(date)
    }
    
    /**
        Creates a new date at the first second of the same day as the given date
    
        - parameter date: The date for which to calculate the beginning of the day
    
        - returns: The newly created date representing the first second of the day
    */
    public func beginningOfDay(date:NSDate) -> NSDate {
        let components = self.calendar.components(
            ([.Year, .Month, .Day]), fromDate: date
        )
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same day as the given date
    
        - parameter date: The date for which to calculate the beginning of the day
    
        - returns: The newly created date representing the first second of the day
    */
    static public func beginningOfDay(date:NSDate) -> NSDate {
        return sharedInstance.beginningOfDay(date)
    }
    
    /**
        Creates a new date at the first second of the same week as the given date
    
        - parameter date: The date for which to calculate the beginning of the week
    
        - returns: The newly created date representing the first second of the week
    */
    public func beginningOfWeek(date:NSDate) -> NSDate {
        let components = self.calendar.components([.Year, .Month, .Day, .Weekday], fromDate: date)
        
        let weekdayOffset = components.weekday - self.calendar.firstWeekday
        components.day -= weekdayOffset;
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same week as the given date
    
        - parameter date: The date for which to calculate the beginning of the week
    
        - returns: The newly created date representing the first second of the week
    */
    static public func beginningOfWeek(date:NSDate) -> NSDate {
        return sharedInstance.beginningOfWeek(date)
    }
    
    /**
        Creates a new date at the first second of the same month as the given 
        date
    
        - parameter date: The date for which to calculate the beginning of the month
    
        - returns: The newly created date representing the first second of the month
    */
    public func beginningOfMonth(date:NSDate) -> NSDate {
        let components = self.calendar.components(([.Year, .Month]), fromDate: date)
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same month as the given 
        date
    
        - parameter date: The date for which to calculate the beginning of the month
    
        - returns: The newly created date representing the first second of the month
    */
    static public func beginningOfMonth(date:NSDate) -> NSDate {
        return sharedInstance.beginningOfMonth(date)
    }
    
    /**
        Creates a new date at the first second of the same year as the given date
    
        - parameter date: The date for which to calculate the beginning of the year
    
        - returns: The newly created date representing the first second of the year
    */
    public func beginningOfYear(date:NSDate) -> NSDate {
        let components = self.calendar.components(.Year, fromDate: date)
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same year as the given date
    
        - parameter date: The date for which to calculate the beginning of the year
    
        - returns: The newly created date representing the first second of the year
    */
    static public func beginningOfYear(date:NSDate) -> NSDate {
        return sharedInstance.beginningOfYear(date)
    }
    
// MARK: - Calculate end of time unit
    
    /**
        Creates a new date at the last second of the same hour as the given date.
    
        - parameter date: The date for which to calculate the end of the month
    
        - returns: The newly created date representing the last second of the hour.
    */
    public func endOfHour(date:NSDate) -> NSDate {
        let firstSecondOfNextHour = self.beginningOfHour(
            self.calendar.dateByAddingUnit(.Hour, value: 1, toDate: date, options: [])!
        )
        
        return firstSecondOfNextHour.dateByAddingTimeInterval(-1)
    }
    
    /**
        Creates a new date at the last second of the same hour as the given date.
    
        - parameter date: The date for which to calculate the end of the month
    
        - returns: The newly created date representing the last second of the hour.
    */
    static public func endOfHour(date:NSDate) -> NSDate {
        return sharedInstance.endOfHour(date)
    }
    
    /**
        Creates a new date at the last second of the same day as the given date.
    
        - parameter date: The date for which to calculate the end of the hour.
    
        - returns: The newly created date representing the last second of the day.
    */
    public func endOfDay(date:NSDate) -> NSDate {
        let firstSecondOfNextDay = self.beginningOfDay(
            self.calendar.dateByAddingUnit(.Day, value: 1, toDate: date, options: [])!
        )
        
        return firstSecondOfNextDay.dateByAddingTimeInterval(-1)
    }
    
    /**
        Creates a new date at the last second of the same day as the given date.
    
        - parameter date: The date for which to calculate the end of the hour.
    
        - returns: The newly created date representing the last second of the day.
    */
    static public func endOfDay(date:NSDate) -> NSDate {
        return sharedInstance.endOfDay(date)
    }
    
    /**
        Creates a new date at the last second of the same week as the given date.
    
        - parameter date: The date for which to calculate the end of the week.
    
        - returns: The newly created date representing the last second of the week.
    */
    public func endOfWeek(date:NSDate) -> NSDate {
        let firstSecondOfNextWeek = self.beginningOfWeek(
            self.calendar.dateByAddingUnit(.WeekOfYear, value: 1, toDate: date, options: [])!
        )
        
        return firstSecondOfNextWeek.dateByAddingTimeInterval(-1)
    }
    
    /**
        Creates a new date at the last second of the same week as the given date.
    
        - parameter date: The date for which to calculate the end of the week.
    
        - returns: The newly created date representing the last second of the week.
    */
    static public func endOfWeek(date:NSDate) -> NSDate {
        return sharedInstance.endOfWeek(date)
    }
    
    /**
        Creates a new date at the last second of the same month as the given date
    
        - parameter date: The date for which to calculate the end of the month
    
        - returns: The newly created date representing the last second of the month
    */
    public func endOfMonth(date:NSDate) -> NSDate {
        let firstSecondOfNextMonth = self.beginningOfMonth(
            self.calendar.dateByAddingUnit(.Month, value: 1, toDate: date, options: [])!
        )
        
        return firstSecondOfNextMonth.dateByAddingTimeInterval(-1)
    }
    
    /**
        Creates a new date at the last second of the same month as the given date
    
        - parameter date: The date for which to calculate the end of the month
    
        - returns: The newly created date representing the last second of the month
    */
    static public func endOfMonth(date:NSDate) -> NSDate {
        return sharedInstance.endOfMonth(date)
    }
    
    /**
        Creates a new date at the last second of the same year as the given date.
    
        - parameter date: The date for which to calculate the end of the year.
    
        - returns: The newly created date representing the last second of the year.
    */
    public func endOfYear(date:NSDate) -> NSDate {
        let firstSecondOfNextYear = self.beginningOfYear(
            self.calendar.dateByAddingUnit(.Year, value: 1, toDate: date, options: [])!
        )
        
        return firstSecondOfNextYear.dateByAddingTimeInterval(-1)
    }
    
    /**
        Creates a new date at the last second of the same year as the given date.
    
        - parameter date: The date for which to calculate the end of the year.
    
        - returns: The newly created date representing the last second of the year.
    */
    static public func endOfYear(date:NSDate) -> NSDate {
        return sharedInstance.endOfYear(date)
    }
    
    
    
// MARK: - Build time units
    
    private func timeUnits(timeUnit:NSCalendarUnit, fromDate:NSDate, toDate:NSDate) -> [NSDate] {
        var currentDate = fromDate
        var timeUnits : [NSDate] = []
        
        while currentDate.compare(toDate) == .OrderedAscending {
            timeUnits.append(currentDate.copy() as! NSDate)
            
            currentDate = self.calendar.dateByAddingUnit(timeUnit, value: 1, toDate: currentDate, options: [])!
        }
        
        return timeUnits
    }
    
    /**
        Creates an array of dates at the first second of each minute of the hour 
        of the given date.
    
        - parameter date: A date within the day for which to create dates.
    
        - returns: The newly created array of dates.
    */
    public func minutesOfHour(date:NSDate) -> [NSDate] {
        let firstMinuteOfHour = self.beginningOfHour(date)
        let firstMinuteOfNextHour = self.beginningOfHour(self.calendar.dateByAddingUnit(
            .Hour, value: 1, toDate: firstMinuteOfHour, options: [])!
        )
        
        return self.timeUnits(.Minute, fromDate: firstMinuteOfHour, toDate: firstMinuteOfNextHour)
    }
    
    /**
        Creates an array of dates at the first second of each minute of the hour 
        of the given date.
    
        - parameter date: A date within the day for which to create dates.
    
        - returns: The newly created array of dates.
    */
    static public func minutesOfHour(date:NSDate) -> [NSDate] {
        return sharedInstance.minutesOfHour(date)
    }
    
    /**
        Creates an array of dates at the first second of each hour of the day of
        the given date.
    
        - parameter date: A date within the day for which to create dates.
    
        - returns: The newly created array of dates.
    */
    public func hoursOfDay(date:NSDate) -> [NSDate] {
        let firstHourOfDay = self.beginningOfDay(date)
        let firstHourOfNextDay = self.beginningOfDay(self.calendar.dateByAddingUnit(
            .Day, value: 1, toDate: firstHourOfDay, options: [])!
        )
        
        return self.timeUnits(.Hour, fromDate: firstHourOfDay, toDate: firstHourOfNextDay)
    }
    
    /**
        Creates an array of dates at the first second of each hour of the day of
        the given date.
    
        - parameter date: A date within the day for which to create dates.
    
        - returns: The newly created array of dates.
    */
    static public func hoursOfDay(date:NSDate) -> [NSDate] {
        return sharedInstance.hoursOfDay(date)
    }
    
    /**
        Creates an array of dates at the first second of each day of the week of
        the given date.
    
        - parameter date: A date within the week for which to create dates.
    
        - returns: The newly created array of dates.
    */
    public func daysOfWeek(date:NSDate) -> [NSDate] {
        let firstDayOfWeek = self.beginningOfWeek(date)
        let firstDayOfNextWeek = self.beginningOfWeek(
            self.calendar.dateByAddingUnit(.WeekOfYear, value: 1, toDate: date, options: [])!
        )
        
        return self.timeUnits(.Day, fromDate: firstDayOfWeek, toDate: firstDayOfNextWeek)
    }
    
    /**
        Creates an array of dates at the first second of each day of the week of
        the given date.
    
        - parameter date: A date within the week for which to create dates.
    
        - returns: The newly created array of dates.
    */
    static public func daysOfWeek(date:NSDate) -> [NSDate] {
        return sharedInstance.daysOfWeek(date)
    }
    
    /**
        Creates an array of dates at midnight on each day of the month of the 
        given date. 
    
        - parameter date: A date within the month for which to create dates.
    
        - returns: The newly created array of dates.
    */
    public func daysOfMonth(date:NSDate) -> [NSDate] {
        let firstDayOfMonth = self.beginningOfMonth(date)
        let firstDayOfNextMonth = self.beginningOfMonth(self.calendar.dateByAddingUnit(
            .Month, value: 1, toDate: firstDayOfMonth, options: [])!
        )
        
        return self.timeUnits(.Day, fromDate: firstDayOfMonth, toDate: firstDayOfNextMonth)
    }
    
    /**
        Creates an array of dates at midnight on each day of the month of the 
        given date. 
    
        - parameter date: A date within the month for which to create dates.
    
        - returns: The newly created array of dates.
    */
    static public func daysOfMonth(date:NSDate) -> [NSDate] {
        return sharedInstance.daysOfMonth(date)
    }
    
    /**
        Creates an array of dates at midnight of the first day of each month of 
        the year of the given date.
    
        - parameter date: A date within the month for which to create dates.
    
        - returns: The newly created array of dates.
    */
    public func monthsOfYear(date:NSDate) -> [NSDate] {
        let firstMonthOfYear = self.beginningOfYear(date)
        let firstMonthOfNextYear = self.beginningOfYear(self.calendar.dateByAddingUnit(
            .Year, value: 1, toDate: firstMonthOfYear, options: [])!
        )
        
        return self.timeUnits(.Month, fromDate: firstMonthOfYear, toDate: firstMonthOfNextYear)
    }
    
    /**
        Creates an array of dates at midnight of the first day of each month of 
        the year of the given date.
    
        - parameter date: A date within the month for which to create dates.
    
        - returns: The newly created array of dates.
    */
    static public func monthsOfYear(date:NSDate) -> [NSDate] {
        return sharedInstance.monthsOfYear(date)
    }
    
    
// MARK: - Determining whether date falls within time unit
    /**
        Returns true if the given date falls on or before the start date and on 
        or before the end date and false otherwise.
    
        - parameter date:      The date to be tested
        - parameter startDate: The beginning of the time range
        - parameter endDate:   The end of the time range
    
        - returns: true if the date falls on or within the given start and end date,
            false otherwise
    */
    private func dateIsBetween(date:NSDate, startDate:NSDate, endDate:NSDate) -> Bool {
        let beforeStartDate = startDate.compare(date) == .OrderedDescending
        let afterEndDate = endDate.compare(date) == .OrderedAscending
        
        return !beforeStartDate && !afterEndDate
    }
    
    /**
        Returns true if the given date falls within the hour of the given hour
        or false otherwise.
    
        - parameter date: The date being tested
        - parameter hour: Any date within the hour of the test range
    
        - returns: True if the given date falls within the hour or false otherwise
    */
    public func hourContainsDate(date:NSDate, hour:NSDate) -> Bool {
        let beginningOfHour = self.beginningOfHour(hour)
        let endOfHour = self.endOfHour(hour)
        
        return self.dateIsBetween(date, startDate: beginningOfHour, endDate: endOfHour)
    }
    
    /**
        Returns true if the given date falls within the hour of the given hour
        or false otherwise.
    
        - parameter date: The date being tested
        - parameter hour: Any date within the hour of the test range
    
        - returns: True if the given date falls within the hour or false otherwise
    */
    static public func hourContainsDate(date:NSDate, hour:NSDate) -> Bool {
        return sharedInstance.hourContainsDate(date, hour: hour)
    }
    
    /**
        Returns true if the given date falls within the day of the given day or
        false otherwise. See also NSCalendar.isDate:inSameDayAsDate method for 
        similar functionality.
    
        - parameter date: The date being tested.
        - parameter day:  Any date within the day of the test range.
    
        - returns: True if the given date falls wtihin the day or false otherwise.
    */
    public func dayContainsDate(date:NSDate, day:NSDate) -> Bool {
        let beginningOfDay = self.beginningOfDay(day)
        let endOfDay = self.endOfDay(day)
        
        return self.dateIsBetween(date, startDate: beginningOfDay, endDate: endOfDay)
    }
    
    /**
        Returns true if the given date falls within the day of the given day or
        false otherwise. See also NSCalendar.isDate:inSameDayAsDate method for 
        similar functionality.
    
        - parameter date: The date being tested.
        - parameter day:  Any date within the day of the test range.
    
        - returns: True if the given date falls wtihin the day or false otherwise.
    */
    static public func dayContainsDate(date:NSDate, day:NSDate) -> Bool {
        return sharedInstance.dayContainsDate(date, day: day)
    }
    
    /**
        Returns true if the given date falls within the week of the given week or
        false otherwise.
    
        - parameter date: The date being tested.
        - parameter week: Any date within the week of the test range.
    
        - returns: True if the given date falls within the week or false otherwise.
    */
    public func weekContainsDate(date:NSDate, week:NSDate) -> Bool {
        let beginningOfWeek = self.beginningOfWeek(week)
        let endOfWeek = self.endOfWeek(week)
        
        return self.dateIsBetween(date, startDate: beginningOfWeek, endDate: endOfWeek)
    }
    
    /**
        Returns true if the given date falls within the week of the given week or
        false otherwise.
    
        - parameter date: The date being tested.
        - parameter week: Any date within the week of the test range.
    
        - returns: True if the given date falls within the week or false otherwise.
    */
    static public func weekContainsDate(date:NSDate, week:NSDate) -> Bool {
        return sharedInstance.weekContainsDate(date, week: week)
    }
    
    /**
        Returns true if the given date falls within the day of the given month 
        or false otherwise.
    
        - parameter date:  The date being tested.
        - parameter month: Any date within the month of the test range.
    
        - returns: True if the given date falls within the month or false otherwise.
    */
    public func monthContainsDate(date:NSDate, month:NSDate) -> Bool {
        let beginningOfMonth = self.beginningOfMonth(month)
        let endOfMonth = self.endOfMonth(month)
        
        return self.dateIsBetween(date, startDate: beginningOfMonth, endDate: endOfMonth)
    }
    
    /**
        Returns true if the given date falls within the day of the given month 
        or false otherwise.
    
        - parameter date:  The date being tested.
        - parameter month: Any date within the month of the test range.
    
        - returns: True if the given date falls within the month or false otherwise.
    */
    static public func monthContainsDate(date:NSDate, month:NSDate) -> Bool {
        return sharedInstance.monthContainsDate(date, month: month)
    }
    
    /**
        Returns true if the given date falls within the year of the given year 
        or false otherwise.
    
        - parameter date: The date being tested.
        - parameter year: Any date within the year of the test range.
    
        - returns: True if the given date falls wtihin the year or false otherwise.
    */
    public func yearContainsDate(date:NSDate, year:NSDate) -> Bool {
        let beginningOfYear = self.beginningOfYear(year)
        let endOfYear = self.endOfYear(year)
        
        return self.dateIsBetween(date, startDate: beginningOfYear, endDate: endOfYear)
    }
    
    /**
        Returns true if the given date falls within the year of the given year 
        or false otherwise.
    
        - parameter date: The date being tested.
        - parameter year: Any date within the year of the test range.
    
        - returns: True if the given date falls wtihin the year or false otherwise.
    */
    static public func yearContainsDate(date:NSDate, year:NSDate) -> Bool {
        return sharedInstance.yearContainsDate(date, year: year)
    }
    
    
// MARK: - Previous and Next Time Units
    
    /**
        Creates a new date at the first second of the hour prior to the given date.
    
        - parameter date: The date for which to find the previous hour
    
        - returns: The newly created date.
    */
    public func hourBefore(date:NSDate) -> NSDate {
        let previousHour = self.calendar.dateByAddingUnit(.Hour, value: -1, toDate: date, options: [])!
        return self.beginningOfHour(previousHour)
    }
    
    /**
        Creates a new date at the first second of the hour prior to the given date.
    
        - parameter date: The date for which to find the previous hour
    
        - returns: The newly created date.
    */
    static public func hourBefore(date:NSDate) -> NSDate {
        return sharedInstance.hourBefore(date)
    }
    
    /**
        Creates a new date at the first second of the hour following the given date.
    
        - parameter date: The date for which to find the next hour
    
        - returns: The newly created date.
    */
    public func hourAfter(date:NSDate) -> NSDate {
        let nextHour = self.calendar.dateByAddingUnit(.Hour, value: 1, toDate: date, options: [])!
        return self.beginningOfHour(nextHour)
    }
    
    /**
        Creates a new date at the first second of the hour following the given date.
    
        - parameter date: The date for which to find the next hour
    
        - returns: The newly created date.
    */
    static public func hourAfter(date:NSDate) -> NSDate {
        return sharedInstance.hourAfter(date)
    }
    
    /**
        Creates a new date at the first second of the day prior to the given date.
    
        - parameter date: The date for which to find the previous day.
    
        - returns: The newly created date.
    */
    public func dayBefore(date:NSDate) -> NSDate {
        let previousDay = self.calendar.dateByAddingUnit(.Day, value: -1, toDate: date, options: [])!
        return self.beginningOfDay(previousDay)
    }
    
    /**
        Creates a new date at the first second of the day prior to the given date.
    
        - parameter date: The date for which to find the previous day.
    
        - returns: The newly created date.
    */
    static public func dayBefore(date:NSDate) -> NSDate {
        return sharedInstance.dayBefore(date)
    }
    
    /**
        Creates a new date at the first second of the day following the given date.
    
        - parameter date: The date for which to find the next day.
    
        - returns: The newly created date.
    */
    public func dayAfter(date:NSDate) -> NSDate {
        let nextDay = self.calendar.dateByAddingUnit(.Day, value: 1, toDate: date, options: [])!
        return self.beginningOfDay(nextDay)
    }
    
    /**
        Creates a new date at the first second of the day following the given date.
    
        - parameter date: The date for which to find the next day.
    
        - returns: The newly created date.
    */
    static public func dayAfter(date:NSDate) -> NSDate {
        return sharedInstance.dayAfter(date)
    }
    
    /**
        Creates a new date at the first second of the week prior to the given date.
    
        - parameter date: The date for which to find the previous week
    
        - returns: The newly created date.
    */
    public func weekBefore(date:NSDate) -> NSDate {
        let previousWeek = self.calendar.dateByAddingUnit(.WeekOfYear, value: -1, toDate: date, options: [])!
        return self.beginningOfWeek(previousWeek)
    }
    
    /**
        Creates a new date at the first second of the week prior to the given date.
    
        - parameter date: The date for which to find the previous week
    
        - returns: The newly created date.
    */
    static public func weekBefore(date:NSDate) -> NSDate {
        return sharedInstance.weekBefore(date)
    }
    
    /**
        Creates a new date at the first second of the week following the given date.
    
        - parameter date: The date for which to find the next week
    
        - returns: The newly created date.
    */
    public func weekAfter(date:NSDate) -> NSDate {
        let nextWeek = self.calendar.dateByAddingUnit(.WeekOfYear, value: 1, toDate: date, options: [])!
        return self.beginningOfWeek(nextWeek)
    }
    
    /**
        Creates a new date at the first second of the week following the given date.
    
        - parameter date: The date for which to find the next week
    
        - returns: The newly created date.
    */
    static public func weekAfter(date:NSDate) -> NSDate {
        return sharedInstance.weekAfter(date)
    }
    
    /**
        Creates a new date at the first second of the month prior to the given date.
    
        - parameter date: The date for which to find the previous month.
    
        - returns: The newly created date.
    */
    public func monthBefore(date:NSDate) -> NSDate {
        let previousMonth = self.calendar.dateByAddingUnit(.Month, value: -1, toDate: date, options: [])!
        return self.beginningOfMonth(previousMonth)
    }
    
    /**
        Creates a new date at the first second of the month prior to the given date.
    
        - parameter date: The date for which to find the previous month.
    
        - returns: The newly created date.
    */
    static public func monthBefore(date:NSDate) -> NSDate {
        return sharedInstance.monthBefore(date)
    }
    
    /**
        Creates a new date at the first second of the month following the given date.
    
        - parameter date: The date for which to find the next month.
    
        - returns: The newly created date.
    */
    public func monthAfter(date:NSDate) -> NSDate {
        let nextMonth = self.calendar.dateByAddingUnit(.Month, value: 1, toDate: date, options: [])!
        return self.beginningOfMonth(nextMonth)
    }
    
    /**
        Creates a new date at the first second of the month following the given date.
    
        - parameter date: The date for which to find the next month.
    
        - returns: The newly created date.
    */
    static public func monthAfter(date:NSDate) -> NSDate {
        return sharedInstance.monthAfter(date)
    }
    
    /**
        Creates a new date at the first second of the year prior to the given date.
    
        - parameter date: The date for which to find the previous year.
    
        - returns: The newly created date.
    */
    public func yearBefore(date:NSDate) -> NSDate {
        let previousYear = self.calendar.dateByAddingUnit(.Year, value: -1, toDate: date, options: [])!
        return self.beginningOfYear(previousYear)
    }
    
    /**
        Creates a new date at the first second of the year prior to the given date.
    
        - parameter date: The date for which to find the previous year.
    
        - returns: The newly created date.
    */
    static public func yearBefore(date:NSDate) -> NSDate {
        return sharedInstance.yearBefore(date)
    }
    
    /**
        Creates a new date at the first second of the year following the given date.
    
        - parameter date: The date for which to find the next year.
    
        - returns: The newly created date.
    */
    public func yearAfter(date:NSDate) -> NSDate {
        let nextYear = self.calendar.dateByAddingUnit(.Year, value: 1, toDate: date, options: [])!
        return self.beginningOfYear(nextYear)
    }
    
    /**
        Creates a new date at the first second of the year following the given date.
    
        - parameter date: The date for which to find the next year.
    
        - returns: The newly created date.
    */
    static public func yearAfter(date:NSDate) -> NSDate {
        return sharedInstance.yearAfter(date)
    }
    
}
