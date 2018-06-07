//
//  CADIncidentType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

/// Protocol for a class representing basic details of an incident
public protocol CADIncidentType: class, CADTaskListItemModelType {

    // MARK: - Network
    var identifier: String { get set }
    var incidentNumber: String { get set }
    var secondaryCode: String? { get set }
    var type: String? { get set }
    var grade: CADIncidentGradeType { get set }
    var patrolGroup: String? { get set }
    var location : CADLocationType? { get set }
    var createdAt: Date? { get set }
    var lastUpdated: Date? { get set }
    var details: String? { get set }
    var informant : CADIncidentInformantType? { get set }
    var locations: [CADLocationType] { get set }
    var persons: [CADIncidentPersonType] { get set }
    var vehicles: [CADIncidentVehicleType] { get set }

    // MARK: - Generated
    var status: CADIncidentStatusType { get }
    var coordinate: CLLocationCoordinate2D? { get }
    var resourceCount: Int { get }
    var resourceCountString: String? { get }
    var createdAtString: String? { get }
}


/// Protocol for a class representing the full details for an incident.
///
/// This information only gets loaded when viewing an individual incident.
public protocol CADIncidentDetailsType: CADIncidentType {

    // MARK: - Network
    var narrative: [CADActivityLogItemType] { get set }
}


/// Equality check without conforming to Equatable, to prevent need for type erasure
public func ==(lhs: CADIncidentType?, rhs: CADIncidentType?) -> Bool {
    return lhs?.incidentNumber == rhs?.incidentNumber
}

/// Inquality check (required when not using Equatable)
public func !=(lhs: CADIncidentType?, rhs: CADIncidentType?) -> Bool {
    return !(lhs?.incidentNumber == rhs?.incidentNumber)
}
