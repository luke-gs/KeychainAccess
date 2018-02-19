//
//  SyncDetailsBroadcastCategoryCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public enum BroadcastCategoryCore: String, Codable, CADBroadcastCategoryType {
    case alert = "Alert"
    case event = "Event"
    case bolf = "BOLF"

    /// All cases, in order of display
    public static var allCases: [CADBroadcastCategoryType] {
        return [
            BroadcastCategoryCore.alert,
            BroadcastCategoryCore.event,
            BroadcastCategoryCore.bolf
        ]
    }

    /// The default case when status is unknown
    public static var defaultCase: CADBroadcastCategoryType = BroadcastCategoryCore.alert

    /// The display title for the unit type
    public var title: String {
        switch self {
        case .alert:
            return NSLocalizedString("Alert", comment: "")
        case .event:
            return NSLocalizedString("Event", comment: "")
        case .bolf:
            return NSLocalizedString("BOLF", comment: "")
        }
    }
}

