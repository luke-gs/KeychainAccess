//
//  SyncDetailsBroadcast.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// TODO: Update this to match API when we get a spec, as this is created based on what the UI needs

open class SyncDetailsBroadcast: Codable, CADBroadcastType {
    open var identifier: String!
    open var type: String!
    open var title: String!
    open var createdAt: Date!
    open var location : SyncDetailsLocation!
    open var lastUpdated: Date!
    open var details: String!

    open var createdAtString: String {
        return DateFormatter.preferredDateTimeStyle.string(from: createdAt)
    }

    /// Type as an enum defined in protocol
    open var categoryType: CADBroadcastCategoryType {
        get {
            return ClientModelTypes.broadcastCategory.init(rawValue: type) ?? ClientModelTypes.broadcastCategory.defaultCase
        }
        set {
            type = newValue.rawValue
        }
    }


}


