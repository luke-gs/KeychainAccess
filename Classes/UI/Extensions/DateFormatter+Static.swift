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
    public static let preferredDateStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        return formatter
    }()

    /// Application should use this formatter to format date and time.
    public static let preferredDateTimeStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy HH:mm")
        return formatter
    }()

    /// Application should use this formatter to format time.
    public static let preferredTimeStyle: DateFormatter = {
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

    @available(*, deprecated, message: "Use preferredDateStyle instead.")
    public static let mediumNumericDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        DateFormatter.isListeningForLocaleChanges = true
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


    // MARK: - Locale changes
    
    private static var isListeningForLocaleChanges: Bool = false {
        didSet {
            if isListeningForLocaleChanges && oldValue == false {
                NotificationCenter.default.addObserver(self, selector: #selector(mpl_currentLocaleDidChange), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
            }
        }
    }
    
    @objc private class func mpl_currentLocaleDidChange() {
        mediumNumericDate.setLocalizedDateFormatFromTemplate("ddMMyyyy")
    }
    
}
