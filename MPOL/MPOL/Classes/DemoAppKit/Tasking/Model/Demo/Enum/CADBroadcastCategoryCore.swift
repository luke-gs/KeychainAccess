//
//  SyncDetailsBroadcastCategoryCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore implementation of enum representing broadcast category type
public enum CADBroadcastCategoryCore: String, Codable, CADBroadcastCategoryType {
    case alert = "Alert"
    case event = "Event"
    case bolf = "BOLF"

    /// All cases, in order of display
    public static var allCases: [CADBroadcastCategoryType] {
        return [
            CADBroadcastCategoryCore.alert,
            CADBroadcastCategoryCore.event,
            CADBroadcastCategoryCore.bolf
        ]
    }

    /// The default case when status is unknown
    public static var defaultCase: CADBroadcastCategoryType = CADBroadcastCategoryCore.alert

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

    /// The display title for the category with a given count of items
    public func pluralTitle(count: Int) -> String? {
        switch self {
        case .alert:
            return String.localizedStringWithFormat(NSLocalizedString("%d Alert(s)", comment: ""), count)
        case .event:
            return String.localizedStringWithFormat(NSLocalizedString("%d Event(s)", comment: ""), count)
        case .bolf:
            return String.localizedStringWithFormat(NSLocalizedString("%d BOLF(s)", comment: ""), count)
        }
    }

}
