//
//  DateFormatter+Static.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/5/17.
//
//

import Foundation

extension DateFormatter {

    /// Application should use this date formatter to format date.
    public static var preferredDateStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        return formatter
    }()

    /// Application should use this formatter to format date and time.
    public static var preferredDateTimeStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy HH:mm")
        return formatter
    }()

    /// Application should use this formatter to format time.
    public static var preferredTimeStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
        return formatter
    }()

    @available(*, deprecated, message: "Use preferredDateStyle instead.")
    public static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    @available(*, deprecated, message: "Use preferredDateTimeStyle instead.")
    public static let longDateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    public static let accurateDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("MMM-d-H:mm:ss.SSSSSSSSS-a-yyyy")
        return formatter
    }()

    public static var mediumDateStyle: Foundation.DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "E dd MMM"
        return formatter
    }()
    
    public static var militaryTimeStyle: Foundation.DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "HHmm"
        return formatter
    }()
    
    
    // MARK - Formatter used in form

    @available(*, deprecated, message: "Use preferredDateStyle instead.")
    public static let formDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy")
        return formatter
    }()

    @available(*, deprecated, message: "Use preferredDateTimeStyle instead.")
    public static let formDateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy HH:mm")
        return formatter
    }()

    @available(*, deprecated, message: "Use preferredTimeStyle instead.")
    public static let formTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
        return formatter
    }()

    // MARK: - Y2K dates, (MPOLA-1325)

    @available(*, deprecated, message: "Use preferredDateStyle instead.")
    public static let shortDateFullYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        return formatter
    }()

    @available(*, deprecated, message: "Use preferredDateTimeStyle instead.")
    public static let shortDateAndTimeFullYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy HH:mm")
        return formatter
    }()

    public static let relativeShortDateAndTimeFullYear: DateFormatter = {
        return RelativeDateFormatter(dateFormatter: preferredDateStyle, timeFormatter: preferredTimeStyle, separator: ", ")
    }()
    
    public static let relativeMediumDateAndMilitaryTime: DateFormatter = {
        return RelativeDateFormatter(dateFormatter: mediumDateStyle, timeFormatter: militaryTimeStyle, separator: ", ")
    }()

}

/// Convenience extension to Date to do conversions for preferred styles
extension Date {
    public func asPreferredDateString() -> String {
        return DateFormatter.preferredDateStyle.string(from: self)
    }

    public func asPreferredDateTimeString() -> String {
        return DateFormatter.preferredDateTimeStyle.string(from: self)
    }

    public func asPreferredTimeString() -> String {
        return DateFormatter.preferredTimeStyle.string(from: self)
    }
}

/// Convenience extension to String to do conversions for preferred styles
extension String {
    public func asPreferredDate() -> Date? {
        return DateFormatter.preferredDateStyle.date(from: self)
    }

    public func asPreferredDateTime() -> Date? {
        return DateFormatter.preferredDateTimeStyle.date(from: self)
    }

    public func asPreferredTime() -> Date? {
        return DateFormatter.preferredTimeStyle.date(from: self)
    }
}

