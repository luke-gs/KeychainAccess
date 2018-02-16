//
//  CADResourceType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

public protocol CADResourceType {
    var callsign: String!  { get }
    var status: String! { get }
    var patrolGroup: String! { get }
    var station: String! { get }
    var currentIncident: String? { get }
    var assignedIncidents: [String]? { get }
    var location: CADLocationType? { get }
    var driver: String? { get }
    var payrollIds: [String]? { get }
    var shiftEnd: Date? { get }
    var shiftStart: Date? { get }
    var type: CADResourceUnitType! { get }
    var serial: String? { get }
    var vehicleCategory: String? { get }
    var equipment: [CADEquipmentType]? { get }
    var remarks : String? { get }
    var lastUpdated : Date? { get }
    var activityLog: [CADActivityLogItemType]? { get }

    var statusType: CADResourceStatusType { get }
    var coordinate: CLLocationCoordinate2D? { get }

    // MARK: - Display Strings

    static var shiftTimeFormatter: DateFormatter { get }
    static var durationTimeFormatter: DateComponentsFormatter { get }

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

extension CADResourceType {
    // Equality
    public static func ==(lhs: CADResourceType, rhs: CADResourceType) -> Bool {
        return lhs.callsign == rhs.callsign
    }
}
