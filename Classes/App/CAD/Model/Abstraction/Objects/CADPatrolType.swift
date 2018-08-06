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
public protocol CADPatrolType: class, CADTaskListItemModelType {

    // MARK: - Network
    var createdAt: Date? { get set }
    var details: String? { get set }
    var identifier: String { get set }
    var lastUpdated: Date? { get set }
    var location : CADLocationType? { get set }
    var patrolGroup: String? { get set }
    var status: CADPatrolStatusType { get set }
    var subtype: String? { get set }
    var type: String? { get set }

    // MARK: - Generated
    var coordinate: CLLocationCoordinate2D? { get }
    var createdAtString: String? { get }
}
