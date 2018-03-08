//
//  CADLocationCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 30/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import CoreLocation

/// PSCore implementation of class representing a location of a resource/incident/etc
open class CADLocationCore: Codable, CADLocationType {

    // MARK: - Network

    open var alertLevel: Int?

    open var country: String?

    open var fullAddress: String?

    open var latitude: Float?

    open var longitude: Float?

    open var postalCode: String?

    open var state: String?

    open var streetName: String?

    open var streetNumberFirst: String?

    open var streetNumberLast: String?

    open var streetType: String?

    open var suburb: String?

    open var coordinate: CLLocationCoordinate2D? {
        if let latitude = latitude, let longitude = longitude {
            return CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        }
        return nil
    }

    open var displayText: String? {
        if let fullAddress = fullAddress {
            return fullAddress
        } else if let suburb = suburb {
            return suburb
        } else if let coordinate = coordinate {
            return "\(coordinate.latitude), \(coordinate.longitude)"
        } else {
            return nil
        }
    }


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
