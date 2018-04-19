//
//  CADAlertLevelCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/4/18.
//

import Foundation

/// PSCore implementation of enum representing alert level
public enum CADAlertLevelCore: Int, Codable, CADAlertLevelType {
    case low    = 0
    case medium = 1
    case high   = 2

    /// All cases, in order of display
    public static var allCases: [CADAlertLevelType] {
        return [
            CADAlertLevelCore.low,
            CADAlertLevelCore.medium,
            CADAlertLevelCore.high
        ]
    }

    /// The display title for the alert level
    public var title: String {
        switch self {
        case .high:
            return NSLocalizedString("High", comment: "Alert Level Title")
        case .medium:
            return NSLocalizedString("Medium", comment: "Alert Level Title")
        case .low:
            return NSLocalizedString("Low", comment: "Alert Level Title")
        }
    }

    /// The color for the alert level
    public var color: UIColor? {
        switch self {
        case .high:
            return .orangeRed
        case .medium:
            return .sunflowerYellow
        case .low:
            return .brightBlue
        }
    }
}
