//
//  PatrolCategoryCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public enum PatrolStatusCore: String, Codable, CADPatrolStatusType {
    case assigned = "Assigned"
    case unassigned = "Unassigned"

    /// All cases, in order of display
    public static var allCases: [CADPatrolStatusType] {
        return [
            PatrolStatusCore.assigned,
            PatrolStatusCore.unassigned
        ]
    }

    /// The default case when status is unknown
    public static var defaultCase: CADPatrolStatusType = PatrolStatusCore.unassigned

    /// The display title for the unit type
    public var title: String {
        switch self {
        case .assigned:
            return NSLocalizedString("Assigned", comment: "")
        case .unassigned:
            return NSLocalizedString("Unassigned", comment: "")
        }
    }

    /// Whether to use dark bakckground when displayed on map
    public var useDarkBackgroundOnMap: Bool {
        switch self {
        case .assigned:
            return true
        default:
            return false
        }
    }
}

