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
open class SyncDetailsResource: Codable, CADResourceType {

    // MARK: - Network

    public var activityLog: [CADActivityLogItemType]?

    public var assignedIncidents: [String]?

    public var callsign: String!

    public var currentIncident: String?

    public var driver: String?

    public var equipment: [CADEquipmentType]?

    public var lastUpdated: Date?

    public var location: CADLocationType?

    public var patrolGroup: String!

    public var payrollIds: [String]?

    public var remarks: String?

    public var serial: String?

    public var shiftEnd: Date?

    public var shiftStart: Date?

    public var station: String!

    public var status: String!

    public var type: CADResourceUnitType!

    public var vehicleCategory: String?

    // MARK: - Generated

    /// Status as a type that is client specific
    open var statusType: CADResourceStatusType {
        get {
            return CADClientModelTypes.resourceStatus.init(rawValue: status) ?? CADClientModelTypes.resourceStatus.defaultCase
        }
        set {
            status = newValue.rawValue
        }
    }

    public var coordinate: CLLocationCoordinate2D? {
        guard let location = location else { return nil }
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }

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

    // MARK: - Static

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

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case activityLog = "activityLog"
        case assignedIncidents = "assignedIncidents"
        case callsign = "callsign"
        case currentIncident = "currentIncident"
        case driver = "driver"
        case equipment = "equipment"
        case lastUpdated = "lastUpdated"
        case location = "location"
        case patrolGroup = "patrolGroup"
        case payrollIds = "payrollIds"
        case remarks = "remarks"
        case serial = "serial"
        case shiftEnd = "shiftEnd"
        case shiftStart = "shiftStart"
        case station = "station"
        case status = "status"
        case type = "type"
        case vehicleCategory = "vehicleCategory"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        activityLog = try values.decodeIfPresent([SyncDetailsActivityLogItem].self, forKey: .activityLog)
        assignedIncidents = try values.decodeIfPresent([String].self, forKey: .assignedIncidents)
        callsign = try values.decodeIfPresent(String.self, forKey: .callsign)
        currentIncident = try values.decodeIfPresent(String.self, forKey: .currentIncident)
        driver = try values.decodeIfPresent(String.self, forKey: .driver)
        equipment = try values.decodeIfPresent([SyncDetailsEquipment].self, forKey: .equipment)
        lastUpdated = try values.decodeIfPresent(Date.self, forKey: .lastUpdated)
        location = try values.decodeIfPresent(SyncDetailsLocation.self, forKey: .location)
        patrolGroup = try values.decodeIfPresent(String.self, forKey: .patrolGroup)
        payrollIds = try values.decodeIfPresent([String].self, forKey: .payrollIds)
        remarks = try values.decodeIfPresent(String.self, forKey: .remarks)
        serial = try values.decodeIfPresent(String.self, forKey: .serial)
        shiftEnd = try values.decodeIfPresent(Date.self, forKey: .shiftEnd)
        shiftStart = try values.decodeIfPresent(Date.self, forKey: .shiftStart)
        station = try values.decodeIfPresent(String.self, forKey: .station)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        type = try values.decodeIfPresent(ResourceTypeCore.self, forKey: .type)
        vehicleCategory = try values.decodeIfPresent(String.self, forKey: .vehicleCategory)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}

extension SyncDetailsResource: Equatable {
    public static func ==(lhs: SyncDetailsResource, rhs: SyncDetailsResource) -> Bool {
        return lhs.callsign == rhs.callsign
    }
}
