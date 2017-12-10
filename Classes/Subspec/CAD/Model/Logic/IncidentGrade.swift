//
//  IncidentGrade.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Enum for incident grades (priorities)
public enum IncidentGrade: String, Codable {
    case p1 = "P1"
    case p2 = "P2"
    case p3 = "P3"
    case p4 = "P4"

    // Return badge text, border and fill color
    var badgeColors: (text: UIColor, border: UIColor, fill: UIColor) {
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
    
    public static var allCases: [IncidentGrade] {
        return [.p1, .p2, .p3, .p4]
    }
}
