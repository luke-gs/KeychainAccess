//
//  SyncDetailsPatrol.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

// TODO: Update this to match API when we get a spec, as this is created based on what the UI needs

open class SyncDetailsPatrol: Codable {
    public enum PatrolStatus: String, Codable {
        case assigned = "Assigned"
        case unassigned = "Unassigned"
    }
    open var identifier: String!
    open var status: PatrolStatus!
    open var type: String!
    open var subtype: String!
    open var patrolGroup: String!
    open var createdAt: Date!
    open var location : SyncDetailsLocation!
    open var lastUpdated: Date!
    open var details: String!
}

extension SyncDetailsPatrol {
    open var createdAtString: String {
        return DateFormatter.preferredDateTimeStyle.string(from: createdAt)
    }
    
    open var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }
}
