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
    
    // Private static instance for static methods
    private static let sharedInstance = TimeUnit()
    
    /// The calendar to be used for date calculations
    lazy var calendar : NSCalendar = {
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
}
