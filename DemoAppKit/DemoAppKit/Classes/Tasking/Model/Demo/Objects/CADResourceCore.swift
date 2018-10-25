//
//  CADResourceCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

/// PSCore implementation of class representing a resource (aka callsign)
open class CADResourceCore: Codable, CADResourceDetailsType {

    // MARK: - Network

    open var activityLog: [CADActivityLogItemType]

    open var assignedIncidents: [String]

    open var callsign: String = ""

    open var category: String?

    open var currentIncident: String?

    open var driver: String?

    open var equipment: [CADEquipmentType]

    open var lastUpdated: Date?

    open var location: CADLocationType?

    open var odometer: String?

    open var patrolGroup: String?

    open var officerIds: [String]

    open var remarks: String?

    open var serial: String?

    open var shiftEnd: Date?

    open var shiftStart: Date?

    open var station: String?

    open var status: CADResourceStatusType

    open var type: CADResourceUnitType

    open var vehicleCategoryId: String?

    // MARK: - Generated

    open var coordinate: CLLocationCoordinate2D? {
        return location?.coordinate
    }

    /// Officer count in format `(n)`. `nil` if no `payrollIds` count
    open var officerCountString: String? {
        return officerIds.count > 0 ? "(\(officerIds.count))" : nil
    }

    /// Shift start string, default format `hh:mm`, 24 hours. `nil` if no shift start time
    open var shiftStartString: String? {
        guard let shiftStart = shiftStart else { return nil }
        return CADResourceCore.shiftTimeFormatter.string(from: shiftStart)
    }

    /// Shift end string, default format `hh:mm`, 24 hours. `nil` if no shift end time
    open var shiftEndString: String? {
        guard let shiftEnd = shiftEnd else { return nil }
        return CADResourceCore.shiftTimeFormatter.string(from: shiftEnd)
    }

    /// Shift duration string, default short format. `nil` if no shift start or end time
    open var shiftDuration: String? {
        guard let shiftStart = shiftStart, let shiftEnd = shiftEnd else { return nil }
        return CADResourceCore.durationTimeFormatter.string(from: shiftEnd.timeIntervalSince(shiftStart))
    }

    /// Equipment list as a string delimited by `separator`. `nil` if no `equipment` count
    public func equipmentListString(separator: String) -> String? {
        if _equipmentListString == nil {
            let quantityPicked = equipment.quantityPicked()
            _equipmentListString = quantityPicked.map { $0.object.title }.joined(separator: separator)
        }
        return _equipmentListString
    }

    /// Internal cached equipment list string, since this is expensive to compute
    private var _equipmentListString: String?

    // MARK: - CADTaskListItemModelType

    /// Create a map annotation for the task list item if location is available
    open func createAnnotation() -> TaskAnnotation? {
        guard let coordinate = coordinate else { return nil }
        return ResourceAnnotation(identifier: callsign,
                                  source: CADTaskListSourceCore.resource,
                                  coordinate: coordinate,
                                  title: callsign,
                                  subtitle: officerCountString,
                                  icon: type.icon,
                                  iconBackgroundColor: status.iconColors.background,
                                  iconTintColor: status.iconColors.icon,
                                  duress: status.isDuress)
    }

    // MARK: - Static

    public static var shiftTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "dd/MM"
        return RelativeDateFormatter(dateFormatter: formatter, timeFormatter: DateFormatter.preferredTimeStyle, separator: ", ")
    }()

    public static var durationTimeFormatter: DateComponentsFormatter = {
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
        case category = "category"
        case currentIncident = "currentIncident"
        case driver = "driver"
        case equipment = "equipment"
        case lastUpdated = "lastUpdated"
        case location = "location"
        case odometer = "odometer"
        case patrolGroup = "patrolGroup"
        case officerIds = "officerIds"
        case remarks = "remarks"
        case serial = "serial"
        case shiftEnd = "shiftEnd"
        case shiftStart = "shiftStart"
        case station = "station"
        case status = "status"
        case type = "type"
        case vehicleCategoryId = "vehicleCategoryId"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        activityLog = try values.decodeIfPresent([CADActivityLogItemCore].self, forKey: .activityLog) ?? []
        assignedIncidents = try values.decodeIfPresent([String].self, forKey: .assignedIncidents) ?? []
        callsign = try values.decodeIfPresent(String.self, forKey: .callsign) ?? ""
        category = try values.decodeIfPresent(String.self, forKey: .category)
        currentIncident = try values.decodeIfPresent(String.self, forKey: .currentIncident)
        driver = try values.decodeIfPresent(String.self, forKey: .driver)
        equipment = try values.decodeIfPresent([CADEquipmentCore].self, forKey: .equipment) ?? []
        lastUpdated = try values.decodeIfPresent(Date.self, forKey: .lastUpdated)
        location = try values.decodeIfPresent(CADLocationCore.self, forKey: .location)
        odometer = try values.decodeIfPresent(String.self, forKey: .odometer)
        patrolGroup = try values.decodeIfPresent(String.self, forKey: .patrolGroup)
        officerIds = try values.decodeIfPresent([String].self, forKey: .officerIds) ?? []
        remarks = try values.decodeIfPresent(String.self, forKey: .remarks)
        serial = try values.decodeIfPresent(String.self, forKey: .serial)
        shiftEnd = try values.decodeIfPresent(Date.self, forKey: .shiftEnd)
        shiftStart = try values.decodeIfPresent(Date.self, forKey: .shiftStart)
        station = try values.decodeIfPresent(String.self, forKey: .station)
        status = try values.decodeIfPresent(CADResourceStatusCore.self, forKey: .status) ?? .unavailable
        type = try values.decodeIfPresent(CADResourceUnitCore.self, forKey: .type) ?? .vehicle
        vehicleCategoryId = try values.decodeIfPresent(String.self, forKey: .vehicleCategoryId)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}

extension CADResourceCore: Equatable {
    public static func ==(lhs: CADResourceCore, rhs: CADResourceCore) -> Bool {
        return lhs.callsign == rhs.callsign
    }
}
