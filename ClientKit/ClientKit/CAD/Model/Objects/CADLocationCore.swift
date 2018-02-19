//
//  CADLocationCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single location in the call to /sync/details
open class CADLocationCore: Codable, CADLocationType {

    // MARK: - Network

    public var alertLevel: Int?

    public var country: String!

    public var fullAddress: String!

    public var latitude: Float!

    public var longitude: Float!

    public var postalCode: String!

    public var state: String!

    public var streetName: String!

    public var streetNumberFirst: String!

    public var streetNumberLast: String!

    public var streetType: String!

    public var suburb: String!

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case country = "country"
        case fullAddress = "fullAddress"
        case latitude = "latitude"
        case longitude = "longitude"
        case postalCode = "postalCode"
        case state = "state"
        case streetName = "streetName"
        case streetNumberFirst = "streetNumberFirst"
        case streetType = "streetType"
        case suburb = "suburb"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        fullAddress = try values.decodeIfPresent(String.self, forKey: .fullAddress)
        latitude = try values.decodeIfPresent(Float.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(Float.self, forKey: .longitude)
        postalCode = try values.decodeIfPresent(String.self, forKey: .postalCode)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        streetName = try values.decodeIfPresent(String.self, forKey: .streetName)
        streetNumberFirst = try values.decodeIfPresent(String.self, forKey: .streetNumberFirst)
        streetType = try values.decodeIfPresent(String.self, forKey: .streetType)
        suburb = try values.decodeIfPresent(String.self, forKey: .suburb)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
