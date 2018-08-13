//
//  CADIncidentGradeCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// PSCore implementation of enum representing incident grade (priority)
public enum CADIncidentGradeCore: String, Codable, CADIncidentGradeType {
    case p1 = "P1"
    case p2 = "P2"
    case p3 = "P3"
    case p4 = "P4"

    /// All cases, in order of display
    public static var allCases: [CADIncidentGradeType] {
        return [
            CADIncidentGradeCore.p1,
            CADIncidentGradeCore.p2,
            CADIncidentGradeCore.p3,
            CADIncidentGradeCore.p4
        ]
    }

    /// The display title for the unit type
    public var title: String {
        switch self {
        case .p1:
            return NSLocalizedString("P1", comment: "")
        case .p2:
            return NSLocalizedString("P2", comment: "")
        case .p3:
            return NSLocalizedString("P3", comment: "")
        case .p4:
            return NSLocalizedString("P4", comment: "")
        }
    }

    // Return badge text, border and fill color
    public var badgeColors: (text: UIColor, border: UIColor, fill: UIColor) {
        switch self {
        case .p1:
            return (.black, .orangeRed, .orangeRed)
        case .p2:
            return (.black, .sunflowerYellow, .sunflowerYellow)
        case .p3:
            return (.secondaryGray, .secondaryGray, .clear)
        case .p4:
            return (.secondaryGray, .secondaryGray, .clear)
        }
    }
    
}
