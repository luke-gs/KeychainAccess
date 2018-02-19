//
//  SyncDetailsPatrol.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation
import MPOLKit

// TODO: Update this to match API when we get a spec, as this is created based on what the UI needs

open class SyncDetailsPatrol: Codable, CADPatrolType {

    // MARK: - Network

    public var createdAt: Date!

    public var details: String!

    public var identifier: String!

    public var lastUpdated: Date!

    public var location: CADLocationType!

    public var patrolGroup: String!

    public var status: String!

    public var subtype: String!

    public var type: String!

    // MARK: - Generated

    open var createdAtString: String {
        return DateFormatter.preferredDateTimeStyle.string(from: createdAt)
    }

    open var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }

    /// Status as a type that is client specific
    open var statusType: CADPatrolStatusType {
        get {
            return ClientModelTypes.patrolStatus.init(rawValue: status) ?? ClientModelTypes.patrolStatus.defaultCase
        }
        set {
            status = newValue.rawValue
        }
    }

}

