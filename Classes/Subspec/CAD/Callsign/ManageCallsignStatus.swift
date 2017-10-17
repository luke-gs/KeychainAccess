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
    case onCell
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
        case .onCell:
            return NSLocalizedString("On Cell", comment: "")
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
            return .sourceBarNone
        case .onAir:
            return .sourceBarNone
        case .mealBreak:
            return .sourceBarNone
        case .trafficStop:
            return .sourceBarNone
        case .court:
            return .sourceBarNone
        case .atStation:
            return .sourceBarNone
        case .onCell:
            return .sourceBarNone
        case .inquiries1:
            return .sourceBarNone
        case .proceeding:
            return .sourceBarNone
        case .atIncident:
            return .sourceBarNone
        case .finalise:
            return .sourceBarNone
        case .inquiries2:
            return .sourceBarNone
        }
    }

    var canTerminate: Bool {
        switch self {
        // Current state where terminating shift is allowed
        case .unavailable: fallthrough
        case .onAir: fallthrough
        case .mealBreak: fallthrough
        case .trafficStop: fallthrough
        case .court: fallthrough
        case .atStation: fallthrough
        case .onCell: fallthrough
        case .inquiries1:
            return true

        // Current state where terminating shift is NOT allowed
        case .proceeding: fallthrough
        case .atIncident: fallthrough
        case .finalise: fallthrough
        case .inquiries2:
            return false
        }
    }

    func canChangeToStatus(newStatus: ManageCallsignStatus) -> Bool {
        // Rather than write entire matrix of true/falses, just check for the few that aren't allowed
        if self == .proceeding && newStatus == .finalise ||
            self == .atIncident && newStatus == .proceeding {
            return false
        }
        return true
    }
}


