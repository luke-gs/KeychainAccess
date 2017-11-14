//
//  ManageCallsignStatus.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Enum for callsign status states and logic from https://gridstone.atlassian.net/browse/MPOLA-520
public enum ManageCallsignStatus: Int {
    // General
    case unavailable
    case onAir
    case mealBreak
    case trafficStop
    case court
    case atStation
    case onCall
    case inquiries1

    // Current task
    case proceeding
    case atIncident
    case finalise
    case inquiries2

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
             .inquiries1:
            return true

        // Current state where terminating shift is NOT allowed
        case .proceeding,
             .atIncident,
             .finalise,
             .inquiries2:
            return false
        }
    }

    func canChangeToStatus(newStatus: ManageCallsignStatus) -> Bool {
        // Rather than write entire matrix of true/falses, just check for the few that aren't allowed
        switch (self, newStatus) {
        case (.proceeding, .finalise),
             (.atIncident, .proceeding):
            return false
        default:
            return true
        }
    }
}


