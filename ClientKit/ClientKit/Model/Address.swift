//
//  Address.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import PublicSafetyKit

private enum CodingKeys: String, CodingKey {
    case type = "addressType"
    case latitude = "latitude"
    case longitude = "longitude"
    case horizontalAccuracy = "horizontalAccuracy"
    case altitude = "altitude"
    case altitudeAccuracy = "altitudeAccuracy"
    case sampleTaken = "sampleTaken"
    case dataAge = "dataAge"
    case postalContainer = "postalContainer"
    case floor = "floor"
    case unit = "unit"
    case streetNumberFirst = "streetNumberFirst"
    case streetNumberLast = "streetNumberLast"
    case streetName = "streetName"
    case streetType = "streetType"
    case streetDirectional = "streetDirectional"
    case county = "county"
    case suburb = "suburb"
    case state = "state"
    case country = "country"
    case postcode = "postcode"
    case commonName = "commonName"
    case fullAddress = "fullAddress"
}

@objc(MPLAddress)
open class Address: Entity {

    override open class var serverTypeRepresentation: String {
        return "Location"
    }
    
    open var type: String?
    open var latitude: Double?
    open var longitude: Double?
    open var horizontalAccuracy: Double?
    
    open var altitude: Double?
    open var altitudeAccuracy: Double?
    
    open var sampleTaken: String?
    open var dataAge: Int?

    open var postalContainer: String?
    open var floor: String?
    open var unit: String?
    open var streetNumberFirst: String?
    open var streetNumberLast: String?
    open var streetName: String?
    open var streetType: String?
    open var streetDirectional: String?
    open var county: String?
    open var suburb: String?
    open var state: String?
    open var country: String?
    open var postcode: String?
    open var commonName: String?
    open var fullAddress: String?

    open var reportDate: Date? {
        return dateUpdated ?? dateCreated ?? nil
    }

    public required override init(id: String = UUID().uuidString) {
        super.init(id: id)
    }

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
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue) as String?
        latitude = aDecoder.decodeObject(of: NSNumber.self, forKey: CodingKeys.latitude.rawValue)?.doubleValue
        longitude = aDecoder.decodeObject(of: NSNumber.self, forKey: CodingKeys.longitude.rawValue)?.doubleValue
        horizontalAccuracy = aDecoder.decodeObject(of: NSNumber.self, forKey: CodingKeys.horizontalAccuracy.rawValue)?.doubleValue
        altitude = aDecoder.decodeObject(of: NSNumber.self, forKey: CodingKeys.altitude.rawValue)?.doubleValue
        altitudeAccuracy = aDecoder.decodeObject(of: NSNumber.self, forKey: CodingKeys.altitudeAccuracy.rawValue)?.doubleValue
        sampleTaken = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.sampleTaken.rawValue) as String?
        dataAge = aDecoder.decodeObject(of: NSNumber.self, forKey: CodingKeys.dataAge.rawValue)?.intValue
        postalContainer = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.postalContainer.rawValue) as String?
        floor = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.floor.rawValue) as String?
        unit = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.unit.rawValue) as String?
        streetNumberFirst = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.streetNumberFirst.rawValue) as String?
        streetNumberLast = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.streetNumberLast.rawValue) as String?
        streetName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.streetName.rawValue) as String?
        streetType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.streetType.rawValue) as String?
        streetDirectional = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.streetDirectional.rawValue) as String?
        county = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.county.rawValue) as String?
        suburb = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.suburb.rawValue) as String?
        state = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.state.rawValue) as String?
        country = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.country.rawValue) as String?
        postcode = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.postcode.rawValue) as String?
        commonName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.commonName.rawValue) as String?
        fullAddress = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.fullAddress.rawValue) as String?
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
        aCoder.encode(latitude, forKey: CodingKeys.latitude.rawValue)
        aCoder.encode(longitude, forKey: CodingKeys.longitude.rawValue)
        aCoder.encode(horizontalAccuracy, forKey: CodingKeys.horizontalAccuracy.rawValue)
        aCoder.encode(altitude, forKey: CodingKeys.altitude.rawValue)
        aCoder.encode(altitudeAccuracy, forKey: CodingKeys.altitudeAccuracy.rawValue)
        aCoder.encode(sampleTaken, forKey: CodingKeys.sampleTaken.rawValue)
        aCoder.encode(dataAge, forKey: CodingKeys.dataAge.rawValue)
        aCoder.encode(postalContainer, forKey: CodingKeys.postalContainer.rawValue)
        aCoder.encode(floor, forKey: CodingKeys.floor.rawValue)
        aCoder.encode(unit, forKey: CodingKeys.unit.rawValue)
        aCoder.encode(streetNumberFirst, forKey: CodingKeys.streetNumberFirst.rawValue)
        aCoder.encode(streetNumberLast, forKey: CodingKeys.streetNumberLast.rawValue)
        aCoder.encode(streetName, forKey: CodingKeys.streetName.rawValue)
        aCoder.encode(streetType, forKey: CodingKeys.streetType.rawValue)
        aCoder.encode(streetDirectional, forKey: CodingKeys.streetDirectional.rawValue)
        aCoder.encode(county, forKey: CodingKeys.county.rawValue)
        aCoder.encode(suburb, forKey: CodingKeys.suburb.rawValue)
        aCoder.encode(state, forKey: CodingKeys.state.rawValue)
        aCoder.encode(country, forKey: CodingKeys.country.rawValue)
        aCoder.encode(postcode, forKey: CodingKeys.postcode.rawValue)
        aCoder.encode(commonName, forKey: CodingKeys.commonName.rawValue)
        aCoder.encode(fullAddress, forKey: CodingKeys.fullAddress.rawValue)
    }

    open override class var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }
}
