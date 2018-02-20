//
//  CADIncidentVehicleCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// PSCore implementation of class representing a vehicle associated with an incident
open class CADIncidentVehicleCore: Codable, CADIncidentVehicleType {

    // MARK: - Network

    open var alertLevel: Int!

    open var bodyType: String!

    open var color: String!

    open var id: String!

    open var plateNumber: String!

    open var source: String!

    open var stolen: Bool!

    open var vehicleDescription: String!

    open var vehicleType: String!

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case alertLevel = "alertLevel"
        case bodyType = "bodyType"
        case color = "color"
        case id = "id"
        case plateNumber = "plateNumber"
        case source = "source"
        case stolen = "stolen"
        case vehicleDescription = "vehicleDescription"
        case vehicleType = "vehicleType"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        alertLevel = try values.decodeIfPresent(Int.self, forKey: .alertLevel)
        bodyType = try values.decodeIfPresent(String.self, forKey: .bodyType)
        color = try values.decodeIfPresent(String.self, forKey: .color)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        plateNumber = try values.decodeIfPresent(String.self, forKey: .plateNumber)
        source = try values.decodeIfPresent(String.self, forKey: .source)
        stolen = try values.decodeIfPresent(Bool.self, forKey: .stolen)
        vehicleDescription = try values.decodeIfPresent(String.self, forKey: .vehicleDescription)
        vehicleType = try values.decodeIfPresent(String.self, forKey: .vehicleType)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}

