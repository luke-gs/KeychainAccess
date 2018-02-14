//
//  SyncDetailsBroadcast.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class SyncDetailsBroadcast: Codable {
    public enum BroadcastType: String, Codable {
        case alert = "Alert"
        case event = "Event"
        case bolf = "BOLF"
    }
    
    open var identifier: String!
    open var type: BroadcastType!
    open var title: String!
    open var createdAt: Date!
    open var location : SyncDetailsLocation!
    open var lastUpdated: Date!
    open var details: String!
}

extension SyncDetailsBroadcast {
    open var createdAtString: String {
        return DateFormatter.preferredDateTimeStyle.string(from: createdAt)
    }
}
