//
//  CADResourceStatusCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
/// PSCore implementation of enum representing resource status
/// See https://gridstone.atlassian.net/browse/MPOLA-520
public enum CADResourceStatusCore: String, Codable, CADResourceStatusType {

    // General
    case unavailable    = "Unavailable"
    case onAir          = "On Air"
    case mealBreak      = "Meal Break"
    case trafficStop    = "Traffic Stop"
    case court          = "Court"
    case atStation      = "At Station"
    case onCall         = "On Call"
    case inquiries1     = "Inquiries1"
    case duress         = "Duress"
    case offDuty        = "Off Duty"

    // Current task
    case proceeding     = "Proceeding"
    case atIncident     = "At Incident"
    case finalise       = "Finalise"
    case inquiries2     = "Inquiries2"

    /// All cases, in order of display
    public static let allCases: [CADResourceStatusType] = [
        CADResourceStatusCore.unavailable,
        CADResourceStatusCore.onAir,
        CADResourceStatusCore.mealBreak,
        CADResourceStatusCore.trafficStop,
        CADResourceStatusCore.court,
        CADResourceStatusCore.atStation,
        CADResourceStatusCore.onCall,
        CADResourceStatusCore.inquiries1,
        CADResourceStatusCore.proceeding,
        CADResourceStatusCore.atIncident,
        CADResourceStatusCore.finalise,
        CADResourceStatusCore.inquiries2
    ]

    /// All cases related to a current incident, in order of display
    public static let incidentCases: [CADResourceStatusType] = [
        CADResourceStatusCore.proceeding,
        CADResourceStatusCore.atIncident,
        CADResourceStatusCore.inquiries2,
        CADResourceStatusCore.finalise
    ]

    /// All cases unrelated to a current incident, in order of display
    public static var generalCases: [CADResourceStatusType] = [
        CADResourceStatusCore.unavailable,
        CADResourceStatusCore.onAir,
        CADResourceStatusCore.mealBreak,
        CADResourceStatusCore.trafficStop,
        CADResourceStatusCore.court,
        CADResourceStatusCore.atStation,
        CADResourceStatusCore.onCall,
        CADResourceStatusCore.inquiries1
    ]

    /// The default case when status is unknown
    public static var defaultCase: CADResourceStatusType = CADResourceStatusCore.unavailable

    /// The default case when creating a new incident
    public static var defaultCreateCase: CADResourceStatusType = CADResourceStatusCore.atIncident

    /// The case for a resource in duress
    public static var duressCase: CADResourceStatusType = CADResourceStatusCore.duress

    /// The case for finalising an incident
    public static var finaliseCase: CADResourceStatusType = CADResourceStatusCore.finalise

    /// The case for traffic stop
    public static var trafficStopCase: CADResourceStatusType = CADResourceStatusCore.trafficStop

    /// Display title for status
    public var title: String {
        switch self {
        case .unavailable:
            return NSLocalizedString("Unavailable", comment: "")
        case .onAir:
            return NSLocalizedString("On Air", comment: "")
        case .mealBreak:
            return NSLocalizedString("Meal Break", comment: "")
        case .trafficStop:
            return NSLocalizedString("Traffic Stop", comment: "")
        case .court:
            return NSLocalizedString("Court", comment: "")
        case .atStation:
            return NSLocalizedString("At Station", comment: "")
        case .onCall:
            return NSLocalizedString("On Call", comment: "")
        case .inquiries1:
            return NSLocalizedString("Inquiries", comment: "")
        case .proceeding:
            return NSLocalizedString("Proceeding", comment: "")
        case .atIncident:
            return NSLocalizedString("At Incident", comment: "")
        case .finalise:
            return NSLocalizedString("Finalise", comment: "")
        case .inquiries2:
            return NSLocalizedString("Inquiries", comment: "")
        case .duress:
            return NSLocalizedString("Duress", comment: "")
        case .offDuty:
            return NSLocalizedString("Off Duty", comment: "")
        }
    }

    public var icon: UIImage? {
        return AssetManager.shared.image(forKey: imageKey)
    }

    private var imageKey: AssetManager.ImageKey {
        switch self {
        case .unavailable:
            return .iconStatusUnavailable
        case .onAir:
            return .iconStatusOnAir
        case .mealBreak:
            return .iconStatusMealBreak
        case .trafficStop:
            return .iconStatusTrafficStop
        case .court:
            return .iconStatusCourt
        case .atStation:
            return .iconStatusStation
        case .onCall:
            return .iconStatusOnCall
        case .inquiries1:
            return .iconStatusInquiries
        case .proceeding:
            return .iconStatusProceeding
        case .atIncident:
            return .iconStatusAtIncident
        case .finalise:
            return .iconStatusFinalise
        case .inquiries2:
            return .iconStatusInquiries
        case .duress:
            return .duress
        case .offDuty:
            return .iconStatusOnAir
        }
    }

    // Return icon color and background color
    public var iconColors: (icon: UIColor, background: UIColor) {
        switch self {
        // Duress
        case .duress:
            return (.black, .orangeRed)
        // Responding
        case .proceeding, .atIncident, .finalise, .inquiries2:
            return (.white, .primaryGray)
        // Not Responding
        case .unavailable, .onAir, .mealBreak, .trafficStop, .court, .atStation, .onCall, .inquiries1, .offDuty:
            return (.black, .midGreen)
        }
    }

    /// Return whether shift can be terminated from current status
    public var canTerminate: Bool {
        switch self {
        // Current state where terminating shift is allowed
        case .unavailable,
             .onAir,
             .mealBreak,
             .trafficStop,
             .court,
             .atStation,
             .onCall,
             .inquiries1,
             .offDuty:
            return true

        // Current state where terminating shift is NOT allowed
        case .proceeding,
             .atIncident,
             .finalise,
             .inquiries2,
             .duress:
            return false
        }
    }

    /// Return whether an incident can be created from current status
    public var canCreateIncident: Bool {
        guard let incidentCases = CADResourceStatusCore.incidentCases as? [CADResourceStatusCore] else { return false }
        return !incidentCases.contains(self)
    }

    /// Whether resources of this status are shown on map
    public var shownOnMap: Bool {
        return self != .offDuty
    }

    /// Return the sort order based on status when resources shown in a list
    public var listOrder: Int {
        // Show 'On Air' first, then 'At Incident', then rest alphabetically by callsign
        switch self {
        case .onAir:
            return 0
        case .atIncident:
            return 1
        default:
            return 2
        }
    }

    /// Return whether status change is allowed, and whether a reason needs to be provided
    public func canChangeToStatus(newStatus: CADResourceStatusType) -> (allowed: Bool, requiresReason: Bool) {
        guard let newStatus = newStatus as? CADResourceStatusCore else { return (false, false) }

        // Currently all status changes are allowed, but a reason is needed if going from an incident
        // to a non incident status. Leaving allowed component of tuple as this is likely to change...

        if isChangingToGeneralStatus(newStatus) {
            // Assigning to incident, requires reason
            return (true, true)
        } else if self != newStatus {
            // New status
            return (true, false)
        } else {
            // No change
            return (false, false)
        }
    }

    /// Convenience for checking if changing to non incident status
    public func isChangingToGeneralStatus(_ newStatus: CADResourceStatusType) -> Bool {
        guard let newStatus = newStatus as? CADResourceStatusCore else { return false }
        guard let incidentCases = CADResourceStatusCore.incidentCases as? [CADResourceStatusCore] else { return false }

        return incidentCases.contains(self) && !incidentCases.contains(newStatus)
    }

}

/// Conformance to Equatable, to allow array lookup
extension CADResourceStatusCore: Equatable {
    public static func == (lhs: CADResourceStatusCore, rhs: CADResourceStatusCore) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
