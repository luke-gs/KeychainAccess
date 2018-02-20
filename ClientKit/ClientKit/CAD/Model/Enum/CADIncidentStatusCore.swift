//
//  CADIncidentStatusCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// PSCore implementation of enum representing incident status
public enum CADIncidentStatusCore: String, CADIncidentStatusType {

    case resourced = "Resourced"
    case unresourced = "Unresourced"
    case current = "Current"
    case assigned = "Assigned"

    /// All cases, in order of display
    public static let allCases: [CADIncidentStatusType] = [
        CADIncidentStatusCore.current,
        CADIncidentStatusCore.assigned,
        CADIncidentStatusCore.resourced,
        CADIncidentStatusCore.unresourced
    ]

    /// The case for when incident is the current incident
    public static var currentCase: CADIncidentStatusType = CADIncidentStatusCore.current

    /// Display title for status
    public var title: String {
        switch self {
        case .resourced:
            return NSLocalizedString("Resourced", comment: "")
        case .unresourced:
            return NSLocalizedString("Unresourced", comment: "")
        case .current:
            return NSLocalizedString("Current Incident", comment: "")
        case .assigned:
            return NSLocalizedString("Assigned", comment: "")
        }
    }

    /// Whether to use dark bakckground when displayed on map
    public var useDarkBackgroundOnMap: Bool {
        switch self {
        case .unresourced:
            return true
        default:
            return false
        }
    }

    /// Returns whether this status can be used to filter out incidents
    public var isFilterable: Bool {
        switch self {
        case .resourced, .unresourced:
            return true
        default:
            return false
        }
    }
}
