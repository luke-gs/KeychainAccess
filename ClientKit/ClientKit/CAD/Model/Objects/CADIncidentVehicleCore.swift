//
//  CADIncidentVehicleCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// Reponse object for a single vehicle in an incident
open class CADIncidentVehicleCore: Codable, CADIncidentVehicleType {

    // MARK: - Network

    public var alertLevel: Int!

    public var bodyType: String!

    public var color: String!

    public var id: String!

    public var plateNumber: String!

    public var source: String!

    public var stolen: Bool!

    public var vehicleDescription: String!

    public var vehicleType: String!

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

