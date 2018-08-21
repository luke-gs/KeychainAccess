//
//  LookupAddress.swift
//  MPOLKit
//
//  Created by Herli Halim on 23/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation
import Unbox

public struct LookupAddress: MPOLKitEntityProtocol, Unboxable {

    public static var serverTypeRepresentation: String {
        return "location"
    }

    public let id: String
    public let fullAddress: String

    public let coordinate: CLLocationCoordinate2D
    public let isAlias: Bool

    // Address components
    public let commonName: String?
    public let country: String?
    public let county: String?
    public let floor: String?
    public let lotNumber: String?
    public let postalCode: String?
    public let state: String?
    public let streetDirectional: String?
    public let streetName: String?
    public let streetNumberEnd: String?
    public let streetNumberFirst: String?
    public let streetNumberLast: String?
    public let streetNumberStart: String?
    public let streetSuffix: String?
    public let streetType: String?
    public let suburb: String?
    public let unitNumber: String?
    public let unitType: String?

    public init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: CodingKeys.id.rawValue)
        fullAddress = try unboxer.unbox(key: CodingKeys.fullAddress.rawValue)

        /* Sad day to be alive, really!
        let latitude = try unboxer.unbox(key: CodingKeys.latitude.rawValue) as CLLocationDegrees
        let longitude = try unboxer.unbox(key: CodingKeys.longitude.rawValue) as CLLocationDegrees
         */
        let latitude = try unboxer.unbox(keyPath: "location.\(CodingKeys.latitude.rawValue)") as CLLocationDegrees
        let longitude = try unboxer.unbox(keyPath: "location.\(CodingKeys.longitude.rawValue)") as CLLocationDegrees
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        isAlias = try unboxer.unbox(key: CodingKeys.isAlias.rawValue)

        commonName = unboxer.unbox(keyPath: "location.\(CodingKeys.commonName.rawValue)")
        country = unboxer.unbox(keyPath: "location.\(CodingKeys.country.rawValue)")
        county = unboxer.unbox(keyPath: "location.\(CodingKeys.county.rawValue)")
        floor = unboxer.unbox(keyPath: "location.\(CodingKeys.floor.rawValue)")
        lotNumber = unboxer.unbox(keyPath: "location.\(CodingKeys.lotNumber.rawValue)")
        postalCode = unboxer.unbox(keyPath: "location.\(CodingKeys.postalCode.rawValue)")
        state = unboxer.unbox(keyPath: "location.\(CodingKeys.state.rawValue)")
        streetDirectional = unboxer.unbox(keyPath: "location.\(CodingKeys.streetDirectional.rawValue)")
        streetName = unboxer.unbox(keyPath: "location.\(CodingKeys.streetName.rawValue)")
        streetNumberEnd = unboxer.unbox(keyPath: "location.\(CodingKeys.streetNumberEnd.rawValue)")
        streetNumberFirst = unboxer.unbox(keyPath: "location.\(CodingKeys.streetNumberFirst.rawValue)")
        streetNumberLast = unboxer.unbox(keyPath: "location.\(CodingKeys.streetNumberLast.rawValue)")
        streetNumberStart = unboxer.unbox(keyPath: "location.\(CodingKeys.streetNumberStart.rawValue)")
        streetSuffix = unboxer.unbox(keyPath: "location.\(CodingKeys.streetSuffix.rawValue)")
        streetType = unboxer.unbox(keyPath: "location.\(CodingKeys.streetType.rawValue)")
        suburb = unboxer.unbox(keyPath: "location.\(CodingKeys.suburb.rawValue)")
        unitNumber = unboxer.unbox(keyPath: "location.\(CodingKeys.unitNumber.rawValue)")
        unitType = unboxer.unbox(keyPath: "location.\(CodingKeys.unitType.rawValue)")
    }

    private enum CodingKeys: String {
        case id = "id"
        case fullAddress = "fullAddress"
        case latitude = "latitude"
        case longitude = "longitude"
        case isAlias = "isAlias"

        case commonName = "commonName"
        case country = "country"
        case county = "county"
        case floor = "floor"
        case lotNumber = "lotNumber"
        case postalCode = "postalCode"
        case state = "state"
        case streetDirectional = "streetDirectional"
        case streetName = "streetName"
        case streetNumberEnd = "streetNumberEnd"
        case streetNumberFirst = "streetNumberFirst"
        case streetNumberLast = "streetNumberLast"
        case streetNumberStart = "streetNumberStart"
        case streetSuffix = "streetSuffix"
        case streetType = "streetType"
        case suburb = "suburb"
        case unitNumber = "unitNumber"
        case unitType = "unitType"
    }

    public func isEssentiallyTheSameAs(otherEntity: MPOLKitEntityProtocol) -> Bool {
        return type(of: self) == type(of: otherEntity) && id == otherEntity.id
    }
}

extension LookupAddress: DefaultCustomStringConvertible {
    
}
