//
//  Date+Extension.swift
//  MPOLKit
//
//  Created by Kyle May on 19/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

enum DateRoundingType {
    case round
    case ceil
    case floor
}

extension Date {
    
    /// Rounds a date to specified minutes
    /// - author: https://stackoverflow.com/a/37261029
    func rounded(minutes: Int, rounding: DateRoundingType = .round) -> Date {
        return rounded(seconds: TimeInterval(minutes * 60), rounding: rounding)
    }
    
    /// Rounds a date to specified seconds
    /// - author: https://stackoverflow.com/a/37261029
    func rounded(seconds: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        var roundedInterval: TimeInterval = 0
        switch rounding  {
        case .round:
            roundedInterval = (timeIntervalSinceReferenceDate / seconds).rounded() * seconds
        case .ceil:
            roundedInterval = ceil(timeIntervalSinceReferenceDate / seconds) * seconds
        case .floor:
            roundedInterval = floor(timeIntervalSinceReferenceDate / seconds) * seconds
        }
        return Date(timeIntervalSinceReferenceDate: roundedInterval)
    }
    
    /// The date at 00:00:00
    var beginningOfDay: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }
    
    /// The date at 23:59:59
    var endOfDay: Date {
        // Get beginning of day, add 1 day to get next day at 00:00:00 then subtract 1 second
        return self.beginningOfDay.adding(days: 1).adding(seconds: -1)
    }
    
    /// The date ignoring anything but hour and minute
    var timeOnly: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        return calendar.date(from: components)!
    }
    
    /// The date ignoring time components
    var dateOnly: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }
    
    /// Gets the date without seconds or milliseconds
    var withoutSeconds: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: components)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self.addingTimeInterval(seconds)
    }
    
    func adding(minutes: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.setValue(minutes, for: .minute)
        
        return calendar.date(byAdding: components, to: self)!
    }
    
    func adding(hours: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.setValue(hours, for: .hour)
        
        return calendar.date(byAdding: components, to: self)!
    }

    func adding(days: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.setValue(days, for: .day)
        
        return calendar.date(byAdding: components, to: self)!
    }
    
    func adding(weeks: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.setValue(weeks, for: .weekOfYear)
        
        return calendar.date(byAdding: components, to: self)!
    }
    
    func adding(months: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.setValue(months, for: .month)
        
        return calendar.date(byAdding: components, to: self)!
    }
    
    func adding(years: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.setValue(years, for: .year)
        
        return calendar.date(byAdding: components, to: self)!
    }
    
}
