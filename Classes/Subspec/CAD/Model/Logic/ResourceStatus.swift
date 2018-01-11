//
//  ResourceStatus.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Enum for callsign status states and logic from https://gridstone.atlassian.net/browse/MPOLA-520
public enum ResourceStatus: String, Codable {
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

    /// All enum cases, in order of display
    public static let allCases: [ResourceStatus] = [.unavailable,.onAir,.mealBreak,.trafficStop,.court,.atStation,.onCall,.inquiries1,.proceeding,.atIncident,.finalise,.inquiries2]

    /// Cases related to an incident
    public static let incidentCases: [ResourceStatus] = [.proceeding,.atIncident,.finalise,.inquiries2]

    var title: String {
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

    var imageKey: AssetManager.ImageKey {
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

    public var icon: UIImage? {
        return AssetManager.shared.image(forKey: imageKey)
    }

    // Return icon color and background color
    var iconColors: (icon: UIColor, background: UIColor) {
        switch self {
        case .unavailable:
            return (.secondaryGray, .disabledGray)
        case .onAir:
            return (.black, .midGreen)
        case .mealBreak:
            return (.secondaryGray, .disabledGray)
        case .trafficStop:
            return (.secondaryGray, .disabledGray)
        case .court:
            return (.secondaryGray, .disabledGray)
        case .atStation:
            return (.secondaryGray, .disabledGray)
        case .onCall:
            return (.secondaryGray, .disabledGray)
        case .inquiries1:
            return (.secondaryGray, .disabledGray)
        case .proceeding:
            return (.secondaryGray, .disabledGray)
        case .atIncident:
            return (.white, .primaryGray)
        case .finalise:
            return (.secondaryGray, .disabledGray)
        case .inquiries2:
            return (.secondaryGray, .disabledGray)
        case .duress:
            return (.black, .orangeRed)
        case .offDuty:
            return (.secondaryGray, .disabledGray)
        }
    }

    var canTerminate: Bool {
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

    // Return whether status change is allowed, and whether a reason needs to be provided
    public func canChangeToStatus(newStatus: ResourceStatus) -> (allowed: Bool, requiresReason: Bool) {

        // Currently all status changes are allowed, but a reason is needed if going from no incident
        // to an incident status. Leaving allowed component of tuple as this is likely to change...

        if !ResourceStatus.incidentCases.contains(self) && ResourceStatus.incidentCases.contains(newStatus) {
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
}


