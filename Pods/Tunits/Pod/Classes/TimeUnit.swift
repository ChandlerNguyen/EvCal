//
//  TimeUnit.swift
//  Pods
//
//  Created by Tom on 9/4/15.
//
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
    private func beginningOfHour(date:NSDate) -> NSDate {
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
    private func beginningOfDay(date:NSDate) -> NSDate {
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
    private func beginningOfMonth(date:NSDate) -> NSDate {
        let components = self.calendar.components((.CalendarUnitYear | .CalendarUnitMonth), fromDate: date)
        
        return self.calendar.dateFromComponents(components)!
    }
    
    /**
        Creates a new date at the first second of the same year as the given date
    
        :param: date The date for which to calculate the beginning of the year
    
        :returns: The newly created date representing the first second of the year
    */
    private func beginningOfYear(date:NSDate) -> NSDate {
        let components = self.calendar.components(.CalendarUnitYear, fromDate: date)
        
        return self.calendar.dateFromComponents(components)!
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
}
