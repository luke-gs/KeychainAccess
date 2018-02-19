//
//  SyncDetailsActivityLogItem.swift
//  MPOLKit
//
//  Created by Kyle May on 3/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Response object for a single activity log item in an incident (narrative) or resource
open class SyncDetailsActivityLogItem: Codable, CADActivityLogItemType {

    public var title: String!

    public var description: String!

    public var source: String!

    public var timestamp: Date!

    public init(title: String!, description: String!, source: String!, timestamp: Date!) {
        self.title = title
        self.description = description
        self.source = source
        self.timestamp = timestamp
    }

    open var color: UIColor {
        switch source {
        case "Duress":
            return .orangeRed
        case "Dispatch":
            return .disabledGray
        default:
            return .primaryGray
        }
    }
}
