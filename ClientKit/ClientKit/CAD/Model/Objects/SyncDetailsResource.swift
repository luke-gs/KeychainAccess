//
//  SyncDetailsResource.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation
import MPOLKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single Resource in the call to /sync/details
open class SyncDetailsResource: Codable {
    open var callsign: String!
    open var status: String!
    open var patrolGroup: String!
    open var station: String!
    open var currentIncident: String?
    open var assignedIncidents: [String]?
    open var location: SyncDetailsLocation?
    open var driver: String?
    open var payrollIds: [String]?
    open var shiftEnd: Date?
    open var shiftStart: Date?
    open var type: CADResourceUnitType!
    open var serial: String?
    open var vehicleCategory: String?
    open var equipment: [SyncDetailsEquipment]?
    open var remarks : String?
    open var lastUpdated : Date?
    open var activityLog: [SyncDetailsActivityLogItem]?

    /// Status as a type that is client specific
    open var statusType: CADResourceStatusType {
        get {
            return ClientModelTypes.resourceStatus.init(rawValue: status) ?? ClientModelTypes.resourceStatus.defaultCase
        }
        set {
            status = newValue.rawValue
        }
    }

    public static func ==(lhs: SyncDetailsResource, rhs: SyncDetailsResource) -> Bool {
        return lhs.callsign == rhs.callsign
    }

    public var coordinate: CLLocationCoordinate2D? {
        guard let location = location else { return nil }
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }

    open static var shiftTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    open static var durationTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }()

    // MARK: - Display Strings

    /// Officer count in format `(n)`. `nil` if no `payrollIds` count
    public var officerCountString: String? {
        guard let payrollIds = payrollIds else { return nil }
        return payrollIds.count > 0 ? "(\(payrollIds.count))" : nil
    }

    /// Shift start string, default format `hh:mm`, 24 hours. `nil` if no shift start time
    public var shiftStartString: String? {
        guard let shiftStart = shiftStart else { return nil }
        return SyncDetailsResource.shiftTimeFormatter.string(from: shiftStart)
    }

    /// Shift end string, default format `hh:mm`, 24 hours. `nil` if no shift end time
    public var shiftEndString: String? {
        guard let shiftEnd = shiftEnd else { return nil }
        return SyncDetailsResource.shiftTimeFormatter.string(from: shiftEnd)
    }

    /// Shift duration string, default short format. `nil` if no shift start or end time
    public var shiftDuration: String? {
        guard let shiftStart = shiftStart, let shiftEnd = shiftEnd else { return nil }
        return SyncDetailsResource.durationTimeFormatter.string(from: shiftEnd.timeIntervalSince(shiftStart))
    }

    /// Equipment list as a string delimited by `separator`. `nil` if no `equipment` count
    public func equipmentListString(separator: String) -> String? {
        guard let equipment = equipment, equipment.count > 0 else { return nil }
        return equipment.map { $0.description }.joined(separator: separator)
    }

}


