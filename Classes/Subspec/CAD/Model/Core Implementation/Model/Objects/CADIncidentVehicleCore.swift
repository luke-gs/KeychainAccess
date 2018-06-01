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
    open var bodyType : String?
    open var id: String?
    open var make : String?
    open var model : String?
    open var primaryColour: String?
    open var plateNumber: String?
    open var source: String?
    open var year : String?

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case alertLevel = "alertLevel"
        case associatedAlertLevel = "associatedAlertLevel"
        case bodyType = "bodyType"
        case id = "id"
        case make = "make"
        case model = "model"
        case primaryColour = "primaryColour"
        case plateNumber = "plateNumber"
        case source = "source"
        case year = "year"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        alertLevel = try values.decodeIfPresent(CADAlertLevelCore.self, forKey: .alertLevel)
        associatedAlertLevel = try values.decodeIfPresent(CADAlertLevelCore.self, forKey: .associatedAlertLevel)
        bodyType = try values.decodeIfPresent(String.self, forKey: .bodyType)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        make = try values.decodeIfPresent(String.self, forKey: .make)
        model = try values.decodeIfPresent(String.self, forKey: .model)
        primaryColour = try values.decodeIfPresent(String.self, forKey: .primaryColour)
        plateNumber = try values.decodeIfPresent(String.self, forKey: .plateNumber)
        source = try values.decodeIfPresent(String.self, forKey: .source)
        year = try values.decodeIfPresent(String.self, forKey: .year)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}

