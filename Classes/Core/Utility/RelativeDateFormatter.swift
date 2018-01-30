//
//  RelativeDateFormatter.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// DateFormatter subclass that handles relative date prefixes alongside custom localised date/time formats
///
/// It uses two date formatters so that we can process the date and time independently without parsing the format string.
/// Created as Framework DateFormatter does not support "doesRelativeDateFormatting" if using a custom date format :(
open class RelativeDateFormatter: DateFormatter {

    /// The localized date formatter
    open let dateFormatter: DateFormatter

    /// The localized time formatter, optional
    open let timeFormatter: DateFormatter?

    /// The separator to use when joining date and time
    open let separator: String

    public init(dateFormatter: DateFormatter, timeFormatter: DateFormatter?, separator: String = " ") {
        self.dateFormatter = dateFormatter
        self.timeFormatter = timeFormatter
        self.separator = separator
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func date(from string: String) -> Date? {
        MPLUnimplemented()
    }

    open override func string(from date: Date) -> String {
        var components: [String] = []

        // Add date component, using relative text if possible
        if let relativeText = date.relativeDateForHuman() {
            components.append(relativeText)
        } else {
            components.append(dateFormatter.string(from: date))
        }

        // Add optional time component
        if let timeFormatter = timeFormatter {
            components.append(timeFormatter.string(from: date))
        }
        return components.joined(separator: separator)
    }
}
