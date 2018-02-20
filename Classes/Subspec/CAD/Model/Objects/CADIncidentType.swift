//
//  CADIncidentType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

/// Protocol for a class representing an incident
public protocol CADIncidentType: class {

    // MARK: - Network
    var identifier: String! { get }
    var secondaryCode: String! { get }
    var type: String! { get }
    var grade: CADIncidentGradeType! { get }
    var patrolGroup: String! { get }
    var location : CADLocationType! { get }
    var createdAt: Date! { get }
    var lastUpdated: Date! { get }
    var details: String! { get }
    var informant : CADIncidentInformantType! { get }
    var locations: [CADLocationType]! { get }
    var persons: [CADIncidentPersonType]! { get }
    var vehicles: [CADIncidentVehicleType]! { get }
    var narrative: [CADActivityLogItemType]! { get }

    // MARK: - Generated
    var status: CADIncidentStatusType { get }
    var coordinate: CLLocationCoordinate2D { get }
    var resourceCount: Int { get }
    var resourceCountString: String? { get }
    var createdAtString: String { get }
}
