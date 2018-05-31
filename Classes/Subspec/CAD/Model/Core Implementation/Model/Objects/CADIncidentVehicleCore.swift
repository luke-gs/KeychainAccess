//
//  CADIncidentVehicleCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore implementation of class representing a vehicle associated with an incident
open class CADIncidentVehicleCore: Codable, CADIncidentVehicleType {

    public var entityType: String? {
        return "Vehicle"
    }

    // MARK: - Network

    open var alertLevel: CADAlertLevelType?

    open var associatedAlertLevel: CADAlertLevelType?

    open var primaryColour: String?

    open var id: String?

    open var plateNumber: String?

    open var source: String?

    open var vehicleDescription: String?

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case alertLevel = "alertLevel"
        case associatedAlertLevel = "associatedAlertLevel"
        case primaryColour = "primaryColour"
        case id = "id"
        case plateNumber = "plateNumber"
        case source = "source"
        case vehicleDescription = "vehicleDescription"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        alertLevel = try values.decodeIfPresent(CADAlertLevelCore.self, forKey: .alertLevel)
        associatedAlertLevel = try values.decodeIfPresent(CADAlertLevelCore.self, forKey: .associatedAlertLevel)
        primaryColour = try values.decodeIfPresent(String.self, forKey: .primaryColour)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        plateNumber = try values.decodeIfPresent(String.self, forKey: .plateNumber)
        source = try values.decodeIfPresent(String.self, forKey: .source)
        vehicleDescription = try values.decodeIfPresent(String.self, forKey: .vehicleDescription)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}

