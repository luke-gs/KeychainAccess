//
//  CADPatrolType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

public protocol CADPatrolType {
    var identifier: String! { get }
    var status: String! { get }
    var type: String! { get }
    var subtype: String! { get }
    var patrolGroup: String! { get }
    var createdAt: Date! { get }
    var location : CADLocationType! { get }
    var lastUpdated: Date! { get }
    var details: String! { get }

    var statusType: CADPatrolStatusType { get }
    var createdAtString: String { get }
    var coordinate: CLLocationCoordinate2D { get }
}
