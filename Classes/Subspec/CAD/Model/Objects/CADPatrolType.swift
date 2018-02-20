//
//  CADPatrolType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

/// Protocol for a class representing a patrol task
public protocol CADPatrolType: class {

    // MARK: - Network
    var createdAt: Date! { get }
    var details: String! { get }
    var identifier: String! { get }
    var lastUpdated: Date! { get }
    var location : CADLocationType! { get }
    var patrolGroup: String! { get }
    var status: CADPatrolStatusType! { get }
    var subtype: String! { get }
    var type: String! { get }

    // MARK: - Generated
    var coordinate: CLLocationCoordinate2D { get }
    var createdAtString: String { get }
}
