//
//  IncidentGradeCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Enum for incident grades (priorities)
public enum IncidentGradeCore: String, Codable, CADIncidentGradeType {
    case p1 = "P1"
    case p2 = "P2"
    case p3 = "P3"
    case p4 = "P4"

    /// All cases, in order of display
    public static var allCases: [CADIncidentGradeType] {
        return [
            IncidentGradeCore.p1,
            IncidentGradeCore.p2,
            IncidentGradeCore.p3,
            IncidentGradeCore.p4
        ]
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
