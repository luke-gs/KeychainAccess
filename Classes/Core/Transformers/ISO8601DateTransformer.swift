//
//  ISO8601DateTransformer.swift
//  MPOL
//
//  Created by Herli Halim on 4/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// This transformer allows the app to recognize the following formats of
/// ISO8601 dates, as apparently the default one only recognizes one format
///
/// Supported date formats are:
/// • FullIsoWithTimezone  - "2018-07-01T12:30:30+10:00"
/// • FullIsoNoTimezone - "2018-07-01T12:30:30"
/// • OnlyDate - "2018-07-01"

public class ISO8601DateTransformer: OptionalTransformer {

    // Not specified anywhere whether it's thread safe, but no reason
    // to believe it's not.

    // Full ISO with time zone - 2018-07-01T12:30:30+10:00
    private lazy var dateFormatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()

    // Full ISO without a timezone - 2018-07-01T12:30:30
    private lazy var noTimeZoneDateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        if let timeZone = customTimeZone {
            dateFormatter.timeZone = timeZone
        }
        dateFormatter.formatOptions = [.withYear,
                                       .withMonth,
                                       .withDay,
                                       .withTime,
                                       .withDashSeparatorInDate,
                                       .withColonSeparatorInTime,
                                       .withColonSeparatorInTimeZone]
        return dateFormatter
    }()

    // Date only ISO format - 2018-07-01
    private lazy var dateOnlyFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        if let timeZone = customTimeZone {
            dateFormatter.timeZone = timeZone
        }
        dateFormatter.formatOptions = [.withYear,
                                       .withMonth,
                                       .withDay,
                                       .withDashSeparatorInDate]
        return dateFormatter
    }()
    
    // Since the underlying formatter is thread-safe, allow this
    // transformer to be shared.
    public static let shared = ISO8601DateTransformer()

    public var customTimeZone: TimeZone? {
        didSet {
            noTimeZoneDateFormatter.timeZone = customTimeZone
            dateOnlyFormatter.timeZone = customTimeZone
        }
    }
    
    public func transform(_ value: String) -> Date? {
        return dateFormatter.date(from: value)
            ?? noTimeZoneDateFormatter.date(from: value)
            ?? dateOnlyFormatter.date(from: value)
    }
    
    public func reverse(_ transformedValue: Date) -> String? {
        return dateFormatter.string(from: transformedValue)
    }
}
