//
//  PersonSearchDateParser.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public struct PersonSearchDateParser {

    // Only have static func, so not initialisable/
    private init() {

    }

    private static let dateOfBirthRegex = try! NSRegularExpression(pattern: PersonParserRegexPattern.dateOfBirth.rawValue)
    public static func dateComponents(from date: String) -> (day: String?, month: String?, year: String) {

        // Year is mandatory.
        guard let match = dateOfBirthRegex.matches(in: date, range: NSRange(location: 0, length: date.count)).first,
            let range = Range(match.range(at: 3), in: date) else {
                fatalError("Invalid date string format")
        }

        var monthRange = Range(match.range(at: 2), in: date)
        var dayRange = Range(match.range(at: 1), in: date)

        if monthRange != nil {
            let newUpper = date.index(monthRange!.upperBound, offsetBy: -1)
            monthRange = monthRange!.lowerBound..<newUpper
        }

        if dayRange != nil {
            let newUpper = date.index(dayRange!.upperBound, offsetBy: -1)
            dayRange = dayRange!.lowerBound..<newUpper
        }

        let day: String?
        let month: String?
        let year = String(date[range])

        if let dayRange = dayRange {
            day = String(date[dayRange])
        } else {
            day = nil
        }

        if let monthRange = monthRange {
            month = String(date[monthRange])
        } else {
            month = nil
        }

        return (day: day, month: month, year: year)
    }
}

