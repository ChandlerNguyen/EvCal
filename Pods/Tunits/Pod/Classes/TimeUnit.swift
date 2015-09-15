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
    
    /// The calendar to be used for date calculations
    lazy var calendar : NSCalendar = {
       return NSCalendar.autoupdatingCurrentCalendar()
    }()
    
// MARK: - Calculate beginning of time unit
    
    /**
        Creates a new date at the first second of the same hour as the given date
    
        :param: date The new date for which to calculate the beginning of the hour
    
        :returns: The newly created date representing the first second of the hour
    */
    public func beginningOfHour(date:NSDate) -> NSDate {
        let components = self.calendar.components(
            (.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour), fromDate: date
        )
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same day as the given date
    
        :param: date The date for which to calculate the beginning of the day
    
        :returns: The newly created date representing the first second of the day
    */
    public func beginningOfDay(date:NSDate) -> NSDate {
        let components = self.calendar.components(
            (.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay), fromDate: date
        )
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same month as the given 
        date
    
        :param: date The date for which to calculate the beginning of the month
    
        :returns: The newly created date representing the first second of the month
    */
    public func beginningOfMonth(date:NSDate) -> NSDate {
        let components = self.calendar.components((.CalendarUnitYear | .CalendarUnitMonth), fromDate: date)
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same year as the given date
    
        :param: date The date for which to calculate the beginning of the year
    
        :returns: The newly created date representing the first second of the year
    */
    public func beginningOfYear(date:NSDate) -> NSDate {
        let components = self.calendar.components(.CalendarUnitYear, fromDate: date)
        
        return self.calendar.dateFromComponents(components)!
    }
    
    
// MARK: - Calculate end of time unit
    
    /**
        Creates a new date at the last second of the same hour as the given date.
    
        :param: date The date for which to calculate the end of the month
    
        :returns: The newly created date representing the last second of the hour.
    */
    public func endOfHour(date:NSDate) -> NSDate {
        let firstSecondOfNextHour = self.beginningOfHour(
            self.calendar.dateByAddingUnit(.CalendarUnitHour, value: 1, toDate: date, options: .allZeros)!
        )
        
        return firstSecondOfNextHour.dateByAddingTimeInterval(-1)
    }
    
    /**
        Creates a new date at the last second of the same day as the given date.
    
        :param: date The date for which to calculate the end of the hour.
    
        :returns: The newly created date representing the last second of the day.
    */
    public func endOfDay(date:NSDate) -> NSDate {
        let firstSecondOfNextDay = self.beginningOfDay(
            self.calendar.dateByAddingUnit(.CalendarUnitDay, value: 1, toDate: date, options: .allZeros)!
        )
        
        return firstSecondOfNextDay.dateByAddingTimeInterval(-1)
    }
    
    /**
        Creates a new date at the last second of the same month as the given date
    
        :param: date The date for which to calculate the end of the month
    
        :returns: The newly created date representing the last second of the month
    */
    public func endOfMonth(date:NSDate) -> NSDate {
        let firstSecondOfNextMonth = self.beginningOfMonth(
            self.calendar.dateByAddingUnit(.CalendarUnitMonth, value: 1, toDate: date, options: .allZeros)!
        )
        
        return firstSecondOfNextMonth.dateByAddingTimeInterval(-1)
    }
    
    /**
        Creates a new date at the last second of the same year as the given date.
    
        :param: date The date for which to calculate the end of the year.
    
        :returns: The newly created date representing the last second of the year.
    */
    public func endOfYear(date:NSDate) -> NSDate {
        let firstSecondOfNextYear = self.beginningOfYear(
            self.calendar.dateByAddingUnit(.CalendarUnitYear, value: 1, toDate: date, options: .allZeros)!
        )
        
        return firstSecondOfNextYear.dateByAddingTimeInterval(-1)
    }
    
    
// MARK: - Build time units
    
    private func timeUnits(timeUnit:NSCalendarUnit, fromDate:NSDate, toDate:NSDate) -> [NSDate] {
        var currentDate = fromDate
        var timeUnits : [NSDate] = []
        
        while currentDate.compare(toDate) == .OrderedAscending {
            timeUnits.append(currentDate.copy() as! NSDate)
            
            currentDate = self.calendar.dateByAddingUnit(timeUnit, value: 1, toDate: currentDate, options: .allZeros)!
        }
        
        return timeUnits
    }
    
    /**
        Creates an array of dates at the first second of each minute of the hour 
        of the given date.
    
        :param: date A date within the day for which to create dates.
    
        :returns: The newly created array of dates.
    */
    public func minutesOfHour(date:NSDate) -> [NSDate] {
        let firstMinuteOfHour = self.beginningOfHour(date)
        let firstMinuteOfNextHour = self.beginningOfHour(self.calendar.dateByAddingUnit(
            .CalendarUnitHour, value: 1, toDate: firstMinuteOfHour, options: .allZeros)!
        )
        
        return self.timeUnits(.CalendarUnitMinute, fromDate: firstMinuteOfHour, toDate: firstMinuteOfNextHour)
    }
    
    /**
        Creates an array of dates at the first second of each hour of the day of
        the given date.
    
        :param: date A date within the day for which to create dates.
    
        :returns: The newly created array of dates.
    */
    public func hoursOfDay(date:NSDate) -> [NSDate] {
        let firstHourOfDay = self.beginningOfDay(date)
        let firstHourOfNextDay = self.beginningOfDay(self.calendar.dateByAddingUnit(
            .CalendarUnitDay, value: 1, toDate: firstHourOfDay, options: .allZeros)!
        )
        
        return self.timeUnits(.CalendarUnitHour, fromDate: firstHourOfDay, toDate: firstHourOfNextDay)
    }
    
    /**
        Creates an array of dates at midnight on each day of the month of the 
        given date. 
    
        :param: date A date within the month for which to create dates.
    
        :returns: The newly created array of dates.
    */
    public func daysOfMonth(date:NSDate) -> [NSDate] {
        let firstDayOfMonth = self.beginningOfMonth(date)
        let firstDayOfNextMonth = self.beginningOfMonth(self.calendar.dateByAddingUnit(
            .CalendarUnitMonth, value: 1, toDate: firstDayOfMonth, options: .allZeros)!
        )
        
        return self.timeUnits(.CalendarUnitDay, fromDate: firstDayOfMonth, toDate: firstDayOfNextMonth)
    }
    
    /**
        Creates an array of dates at midnight of the first day of each month of 
        the year of the given date.
    
        :param: date A date within the month for which to create dates.
    
        :returns: The newly created array of dates.
    */
    public func monthsOfYear(date:NSDate) -> [NSDate] {
        let firstMonthOfYear = self.beginningOfYear(date)
        let firstMonthOfNextYear = self.beginningOfYear(self.calendar.dateByAddingUnit(
            .CalendarUnitYear, value: 1, toDate: firstMonthOfYear, options: .allZeros)!
        )
        
        return self.timeUnits(.CalendarUnitMonth, fromDate: firstMonthOfYear, toDate: firstMonthOfNextYear)
    }
    
    
// MARK: - Determining whether date falls within time unit
    /**
        Returns true if the given date falls on or before the start date and on 
        or before the end date and false otherwise.
    
        :param: date      The date to be tested
        :param: startDate The beginning of the time range
        :param: endDate   The end of the time range
    
        :returns: true if the date falls on or within the given start and end date,
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
    
        :param: date The date being tested
        :param: hour Any date within the hour of the test range
    
        :returns: True if the given date falls within the hour or false otherwise
    */
    public func hourContainsDate(date:NSDate, hour:NSDate) -> Bool {
        let beginningOfHour = self.beginningOfHour(hour)
        let endOfHour = self.endOfHour(hour)
        
        return self.dateIsBetween(date, startDate: beginningOfHour, endDate: endOfHour)
    }
    
    /**
        Returns true if the given date falls within the day of the given day or
        false otherwise. See also NSCalendar.isDate:inSameDayAsDate method for 
        similar functionality.
    
        :param: date The date being tested.
        :param: day  Any date within the day of the test range.
    
        :returns: True if the given date falls wtihin the day or false otherwise.
    */
    public func dayContainsDate(date:NSDate, day:NSDate) -> Bool {
        let beginningOfDay = self.beginningOfDay(day)
        let endOfDay = self.endOfDay(day)
        
        return self.dateIsBetween(date, startDate: beginningOfDay, endDate: endOfDay)
    }
    
    /**
        Returns true if the given date falls within the day of the given month 
        or false otherwise.
    
        :param: date  The date being tested.
        :param: month Any date within the month of the test range.
    
        :returns: True if the given date falls within the month or false otherwise.
    */
    public func monthContainsDate(date:NSDate, month:NSDate) -> Bool {
        let beginningOfMonth = self.beginningOfMonth(month)
        let endOfMonth = self.endOfMonth(month)
        
        return self.dateIsBetween(date, startDate: beginningOfMonth, endDate: endOfMonth)
    }
    
    /**
        Returns true if the given date falls within the year of the given year 
        or false otherwise.
    
        :param: date The date being tested.
        :param: year Any date within the year of the test range.
    
        :returns: True if the given date falls wtihin the year or false otherwise.
    */
    public func yearContainsDate(date:NSDate, year:NSDate) -> Bool {
        let beginningOfYear = self.beginningOfYear(year)
        let endOfYear = self.endOfYear(year)
        
        return self.dateIsBetween(date, startDate: beginningOfYear, endDate: endOfYear)
    }
}
