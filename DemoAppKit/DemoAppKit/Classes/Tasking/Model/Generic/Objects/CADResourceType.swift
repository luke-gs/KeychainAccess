//
//  CADResourceType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

/// Protocol for a class representing a resource (aka callsign)
public protocol CADResourceType: class, Codable, CADTaskListItemModelType {

    // MARK: - Network

    var assignedIncidents: [String] { get set}
    var callsign: String { get set }
    var category: String? { get set }
    var currentIncident: String? { get set }
    var driver: String? { get set }
    var equipment: [CADEquipmentType] { get set }
    var lastUpdated: Date? { get set }
    var location: CADLocationType? { get set }
    var odometer: String? { get set }
    var patrolGroup: String? { get set }
    var ids: [String] { get set }
    var remarks: String? { get set }
    var serial: String? { get set }
    var shiftEnd: Date? { get set }
    var shiftStart: Date? { get set }
    var station: String? { get set }
    var status: CADResourceStatusType { get set }
    var type: CADResourceUnitType { get set }
    var vehicleCategoryId: String? { get set }

    // MARK: - Generated
    var coordinate: CLLocationCoordinate2D? { get }

    /// Officer count in format `(n)`. `nil` if no `payrollIds` count
    var officerCountString: String? { get }

    /// Shift start string, default format `hh:mm`, 24 hours. `nil` if no shift start time
    var shiftStartString: String? { get }

    /// Shift end string, default format `hh:mm`, 24 hours. `nil` if no shift end time
    var shiftEndString: String? { get }

    /// Shift duration string, default short format. `nil` if no shift start or end time
    var shiftDuration: String? { get }

    /// Equipment list as a string delimited by `separator`. `nil` if no `equipment` count
    func equipmentListString(separator: String) -> String?
}

/// Protocol for a class representing the full details for a resource.
///
/// This information only gets loaded when viewing an individual resource.
public protocol CADResourceDetailsType: CADResourceType {

    // MARK: - Network
    var activityLog: [CADActivityLogItemType] { get set }
}

// MARK: - Equality
public func ==(lhs: CADResourceType?, rhs: CADResourceType?) -> Bool {
    return lhs?.callsign == rhs?.callsign
}
