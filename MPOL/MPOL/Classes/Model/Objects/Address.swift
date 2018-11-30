//
//  Address.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import PublicSafetyKit

@objc(MPLAddress)
open class Address: Entity {

    // MARK: - Class

    open override class var serverTypeRepresentation: String {
        return "Location"
    }

    open override class var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }

    public override init(id: String) {
        super.init(id: id)
    }

    // MARK: - Properties

    public var altitude: Double?
    public var altitudeAccuracy: Double?
    public var commonName: String?
    public var country: String?
    public var county: String?
    public var dataAge: Int?
    public var floor: String?
    public var fullAddress: String?
    public var horizontalAccuracy: Double?
    public var latitude: Double?
    public var longitude: Double?
    public var postalContainer: String?
    public var postcode: String?
    public var sampleTaken: String?
    public var state: String?
    public var streetDirectional: String?
    public var streetName: String?
    public var streetNumberFirst: String?
    public var streetNumberLast: String?
    public var streetType: String?
    public var suburb: String?
    public var type: String?
    public var unit: String?

    // MARK: - Calculated

    public var reportDate: Date? {
        return dateUpdated ?? dateCreated ?? nil
    }

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {

        try super.init(unboxer: unboxer)

        type = unboxer.unbox(key: CodingKeys.type.rawValue)
        latitude = unboxer.unbox(key: "latitude")
        longitude = unboxer.unbox(key: "longitude")
        horizontalAccuracy = unboxer.unbox(key: "horizontalAccuracy")

        altitude = unboxer.unbox(key: "altitude")
        altitudeAccuracy = unboxer.unbox(key: "altitudeAccuracy")

        sampleTaken = unboxer.unbox(key: "sampleTaken")
        dataAge = unboxer.unbox(key: "dataAge")

        postalContainer = unboxer.unbox(key: "postalContainer")
        floor = unboxer.unbox(key: "floor")
        unit = unboxer.unbox(key: "unit")
        streetNumberFirst = unboxer.unbox(key: "streetNumberFirst")
        streetNumberLast = unboxer.unbox(key: "streetNumberLast")
        streetName = unboxer.unbox(key: "streetName")
        streetType = unboxer.unbox(key: "streetType")
        streetDirectional = unboxer.unbox(key: "streetDirectional")
        county = unboxer.unbox(key: "county")
        suburb = unboxer.unbox(key: "suburb")
        state = unboxer.unbox(key: "state")
        country = unboxer.unbox(key: "country")
        postcode = unboxer.unbox(key: "postalCode")

        commonName = unboxer.unbox(key: "commonName")
        fullAddress = unboxer.unbox(key: "fullAddress")
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case altitude
        case altitudeAccuracy
        case commonName
        case country
        case county
        case dataAge
        case floor
        case fullAddress
        case horizontalAccuracy
        case latitude
        case longitude
        case postalContainer
        case postcode
        case sampleTaken
        case state
        case streetDirectional
        case streetName
        case streetNumberFirst
        case streetNumberLast
        case streetType
        case suburb
        case type
        case unit
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        altitude = try container.decodeIfPresent(Double.self, forKey: .altitude)
        altitudeAccuracy = try container.decodeIfPresent(Double.self, forKey: .altitudeAccuracy)
        commonName = try container.decodeIfPresent(String.self, forKey: .commonName)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        county = try container.decodeIfPresent(String.self, forKey: .county)
        dataAge = try container.decodeIfPresent(Int.self, forKey: .dataAge)
        floor = try container.decodeIfPresent(String.self, forKey: .floor)
        fullAddress = try container.decodeIfPresent(String.self, forKey: .fullAddress)
        horizontalAccuracy = try container.decodeIfPresent(Double.self, forKey: .horizontalAccuracy)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        postalContainer = try container.decodeIfPresent(String.self, forKey: .postalContainer)
        postcode = try container.decodeIfPresent(String.self, forKey: .postcode)
        sampleTaken = try container.decodeIfPresent(String.self, forKey: .sampleTaken)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        streetDirectional = try container.decodeIfPresent(String.self, forKey: .streetDirectional)
        streetName = try container.decodeIfPresent(String.self, forKey: .streetName)
        streetNumberFirst = try container.decodeIfPresent(String.self, forKey: .streetNumberFirst)
        streetNumberLast = try container.decodeIfPresent(String.self, forKey: .streetNumberLast)
        streetType = try container.decodeIfPresent(String.self, forKey: .streetType)
        suburb = try container.decodeIfPresent(String.self, forKey: .suburb)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        unit = try container.decodeIfPresent(String.self, forKey: .unit)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(altitude, forKey: CodingKeys.altitude)
        try container.encode(altitudeAccuracy, forKey: CodingKeys.altitudeAccuracy)
        try container.encode(commonName, forKey: CodingKeys.commonName)
        try container.encode(country, forKey: CodingKeys.country)
        try container.encode(county, forKey: CodingKeys.county)
        try container.encode(dataAge, forKey: CodingKeys.dataAge)
        try container.encode(floor, forKey: CodingKeys.floor)
        try container.encode(fullAddress, forKey: CodingKeys.fullAddress)
        try container.encode(horizontalAccuracy, forKey: CodingKeys.horizontalAccuracy)
        try container.encode(latitude, forKey: CodingKeys.latitude)
        try container.encode(longitude, forKey: CodingKeys.longitude)
        try container.encode(postalContainer, forKey: CodingKeys.postalContainer)
        try container.encode(postcode, forKey: CodingKeys.postcode)
        try container.encode(sampleTaken, forKey: CodingKeys.sampleTaken)
        try container.encode(state, forKey: CodingKeys.state)
        try container.encode(streetDirectional, forKey: CodingKeys.streetDirectional)
        try container.encode(streetName, forKey: CodingKeys.streetName)
        try container.encode(streetNumberFirst, forKey: CodingKeys.streetNumberFirst)
        try container.encode(streetNumberLast, forKey: CodingKeys.streetNumberLast)
        try container.encode(streetType, forKey: CodingKeys.streetType)
        try container.encode(suburb, forKey: CodingKeys.suburb)
        try container.encode(type, forKey: CodingKeys.type)
        try container.encode(unit, forKey: CodingKeys.unit)
    }
}

extension Address: AddressNavigatable {
    public func addressStringRepresentation() -> String? {
        if let fullAddress = fullAddress {
            return fullAddress
        } else if let suburb = suburb {
            return suburb
        } else if let coordinate = coordinate() {
            return "\(coordinate.latitude), \(coordinate.longitude)"
        } else {
            return nil
        }
    }
}
