//
//  Address.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

private enum Coding: String {
    case id = "id"
    case dateCreated = "dateCreated"
    case dateUpdated = "dateUpdated"
    case createdBy = "createdBy"
    case updatedBy = "updatedBy"
    case effectiveDate = "effectiveDate"
    case expiryDate = "expiryDate"
    case entityType = "entityType"
    case isSummary = "isSummary"
    case arn = "arn"
    case jurisdiction = "jurisdiction"
    case source = "source"
    case alertLevel = "alertLevel"
    case associatedAlertLevel = "associatedAlertLevel"
    case alerts = "alerts"
    case associatedPersons = "associatedPersons"
    case associatedVehicles = "associatedVehicles"
    case events = "events"
    case addresses = "addresses"
    case media = "media"
    case type = "type"
    case latitude = "latitude"
    case longitude = "longitude"
    case horizontalAccuracy = "horizontalAccuracy"
    case altitude = "altitude"
    case altitudeAccuracy = "altitudeAccuracy"
    case sampleTaken = "sampleTaken"
    case dataAge = "dataAge"
    case addressType = "addressType"
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
open class Address: NSObject, Serialisable {
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    open class var serverTypeRepresentation: String {
        return "location"
    }
    
    open let id: String
    
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool = false
    open var arn: String?
    open var jurisdiction: String?

    open var source: MPOLSource?
    open var alertLevel: Alert.Level?
    open var associatedAlertLevel: Alert.Level?

    open var alerts: [Alert]?
    open var associatedPersons: [Person]?
    open var associatedVehicles: [Vehicle]?
    open var events: [Event]?
    open var addresses: [Address]?
    open var media: [Media]?
    
    open var type: String?
    open var latitude: Double?
    open var longitude: Double?
    open var horizontalAccuracy: Double?
    
    open var altitude: Double?
    open var altitudeAccuracy: Double?
    
    open var sampleTaken: String?
    open var dataAge: Int?
    
    open var addressType: String?
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

    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }

    public required init(unboxer: Unboxer) throws {
        
        // Test data doesn't have id, temporarily removed this
        //        guard let id: String = unboxer.unbox(key: "id") else {
        //            throw ParsingError.missingRequiredField
        //        }
        //
        if let id: String = unboxer.unbox(key: "id") {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Address.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Address.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Address.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Address.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        arn = unboxer.unbox(key: "arn")
        jurisdiction = unboxer.unbox(key: "jurisdiction")
        
        source = unboxer.unbox(key: "source")
        alertLevel = unboxer.unbox(key: "alertLevel")
        associatedAlertLevel = unboxer.unbox(key: "associatedAlertLevel")
        
        alerts = unboxer.unbox(key: "alerts")
        associatedPersons = unboxer.unbox(key: "persons")
        associatedVehicles = unboxer.unbox(key: "vehicles")
        events = unboxer.unbox(key: "events")
        addresses = unboxer.unbox(key: "locations")
        media = unboxer.unbox(key: "media")
        
        type = unboxer.unbox(key: "locationType")
        latitude = unboxer.unbox(key: "latitude")
        longitude = unboxer.unbox(key: "longitude")
        horizontalAccuracy = unboxer.unbox(key: "horizontalAccuracy")
        
        altitude = unboxer.unbox(key: "altitude")
        altitudeAccuracy = unboxer.unbox(key: "altitudeAccuracy")
        
        sampleTaken = unboxer.unbox(key: "sampleTaken")
        dataAge = unboxer.unbox(key: "dataAge")
        
        addressType = unboxer.unbox(key: "addressType")
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
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: Coding.id.rawValue) as String!
        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.dateUpdated.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: Coding.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: Coding.updatedBy.rawValue) as String?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.effectiveDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.expiryDate.rawValue) as Date?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.entityType.rawValue) as String?
        isSummary = aDecoder.decodeBool(forKey: Coding.isSummary.rawValue)
        arn = aDecoder.decodeObject(of: NSString.self, forKey: Coding.arn.rawValue) as String?
        jurisdiction = aDecoder.decodeObject(of: NSString.self, forKey: Coding.jurisdiction.rawValue) as String?
        alerts = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.alerts.rawValue) as? [Alert]
        associatedPersons = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.associatedPersons.rawValue) as! [Person]?
        associatedVehicles = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.associatedVehicles.rawValue) as! [Vehicle]?
        events = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.events.rawValue) as! [Event]?
        addresses = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.addresses.rawValue) as! [Address]?
        media = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.media.rawValue) as! [Media]?
        type = aDecoder.decodeObject(of: NSString.self, forKey: Coding.type.rawValue) as String?
        latitude = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.latitude.rawValue)?.doubleValue
        longitude = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.longitude.rawValue)?.doubleValue
        horizontalAccuracy = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.horizontalAccuracy.rawValue)?.doubleValue
        altitude = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.altitude.rawValue)?.doubleValue
        altitudeAccuracy = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.altitudeAccuracy.rawValue)?.doubleValue
        sampleTaken = aDecoder.decodeObject(of: NSString.self, forKey: Coding.sampleTaken.rawValue) as String?
        dataAge = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.dataAge.rawValue)?.intValue
        addressType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.addressType.rawValue) as String?
        postalContainer = aDecoder.decodeObject(of: NSString.self, forKey: Coding.postalContainer.rawValue) as String?
        floor = aDecoder.decodeObject(of: NSString.self, forKey: Coding.floor.rawValue) as String?
        unit = aDecoder.decodeObject(of: NSString.self, forKey: Coding.unit.rawValue) as String?
        streetNumberFirst = aDecoder.decodeObject(of: NSString.self, forKey: Coding.streetNumberFirst.rawValue) as String?
        streetNumberLast = aDecoder.decodeObject(of: NSString.self, forKey: Coding.streetNumberLast.rawValue) as String?
        streetName = aDecoder.decodeObject(of: NSString.self, forKey: Coding.streetName.rawValue) as String?
        streetType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.streetType.rawValue) as String?
        streetDirectional = aDecoder.decodeObject(of: NSString.self, forKey: Coding.streetDirectional.rawValue) as String?
        county = aDecoder.decodeObject(of: NSString.self, forKey: Coding.county.rawValue) as String?
        suburb = aDecoder.decodeObject(of: NSString.self, forKey: Coding.suburb.rawValue) as String?
        state = aDecoder.decodeObject(of: NSString.self, forKey: Coding.state.rawValue) as String?
        country = aDecoder.decodeObject(of: NSString.self, forKey: Coding.country.rawValue) as String?
        postcode = aDecoder.decodeObject(of: NSString.self, forKey: Coding.postcode.rawValue) as String?
        commonName = aDecoder.decodeObject(of: NSString.self, forKey: Coding.commonName.rawValue) as String?
        fullAddress = aDecoder.decodeObject(of: NSString.self, forKey: Coding.fullAddress.rawValue) as String?

        if let source = aDecoder.decodeObject(of: NSString.self, forKey: Coding.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }
        
        if aDecoder.containsValue(forKey: Coding.alertLevel.rawValue), let level = Alert.Level(rawValue: aDecoder.decodeObject(forKey: Coding.alertLevel.rawValue) as! Int) {
            alertLevel = level
        }
        
        if aDecoder.containsValue(forKey: Coding.associatedAlertLevel.rawValue), let level = Alert.Level(rawValue: aDecoder.decodeObject(forKey: Coding.alertLevel.rawValue) as! Int) {
            associatedAlertLevel = level
        }
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Coding.id.rawValue)
        aCoder.encode(dateCreated, forKey: Coding.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: Coding.dateUpdated.rawValue)
        aCoder.encode(createdBy, forKey: Coding.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: Coding.updatedBy.rawValue)
        aCoder.encode(effectiveDate, forKey: Coding.effectiveDate.rawValue)
        aCoder.encode(expiryDate, forKey: Coding.expiryDate.rawValue)
        aCoder.encode(entityType, forKey: Coding.entityType.rawValue)
        aCoder.encode(isSummary, forKey: Coding.isSummary.rawValue)
        aCoder.encode(arn, forKey: Coding.arn.rawValue)
        aCoder.encode(jurisdiction, forKey: Coding.jurisdiction.rawValue)
        aCoder.encode(source?.rawValue, forKey: Coding.source.rawValue)
        aCoder.encode(alertLevel?.rawValue, forKey: Coding.alertLevel.rawValue)
        aCoder.encode(associatedAlertLevel?.rawValue, forKey: Coding.associatedAlertLevel.rawValue)
        aCoder.encode(alerts, forKey: Coding.alerts.rawValue)
        aCoder.encode(associatedPersons, forKey: Coding.associatedPersons.rawValue)
        aCoder.encode(associatedVehicles, forKey: Coding.associatedVehicles.rawValue)
        aCoder.encode(events, forKey: Coding.events.rawValue)
        aCoder.encode(addresses, forKey: Coding.addresses.rawValue)
        aCoder.encode(media, forKey: Coding.media.rawValue)
        aCoder.encode(type, forKey: Coding.type.rawValue)
        aCoder.encode(latitude, forKey: Coding.latitude.rawValue)
        aCoder.encode(longitude, forKey: Coding.longitude.rawValue)
        aCoder.encode(horizontalAccuracy, forKey: Coding.horizontalAccuracy.rawValue)
        aCoder.encode(altitude, forKey: Coding.altitude.rawValue)
        aCoder.encode(altitudeAccuracy, forKey: Coding.altitudeAccuracy.rawValue)
        aCoder.encode(sampleTaken, forKey: Coding.sampleTaken.rawValue)
        aCoder.encode(dataAge, forKey: Coding.dataAge.rawValue)
        aCoder.encode(addressType, forKey: Coding.addressType.rawValue)
        aCoder.encode(postalContainer, forKey: Coding.postalContainer.rawValue)
        aCoder.encode(floor, forKey: Coding.floor.rawValue)
        aCoder.encode(unit, forKey: Coding.unit.rawValue)
        aCoder.encode(streetNumberFirst, forKey: Coding.streetNumberFirst.rawValue)
        aCoder.encode(streetNumberLast, forKey: Coding.streetNumberLast.rawValue)
        aCoder.encode(streetName, forKey: Coding.streetName.rawValue)
        aCoder.encode(streetType, forKey: Coding.streetType.rawValue)
        aCoder.encode(streetDirectional, forKey: Coding.streetDirectional.rawValue)
        aCoder.encode(county, forKey: Coding.county.rawValue)
        aCoder.encode(suburb, forKey: Coding.suburb.rawValue)
        aCoder.encode(state, forKey: Coding.state.rawValue)
        aCoder.encode(country, forKey: Coding.country.rawValue)
        aCoder.encode(postcode, forKey: Coding.postcode.rawValue)
        aCoder.encode(commonName, forKey: Coding.commonName.rawValue)
        aCoder.encode(fullAddress, forKey: Coding.fullAddress.rawValue)
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
        
    // MARK: - Temp Formatters
    
    func formattedLines(includingName: Bool = true) -> [String]? {
        var lines: [[String]] = []
        
        if includingName, let name = commonName, !name.isEmpty {
            lines.append([name])
        }
// TODO:       if let postalBox = postalBox {
//            lines.append([postalBox])
//        }
        
        var line: [String] = []
        if let unitNumber = self.unit?.ifNotEmpty() { line.append("Unit \(unitNumber)") }
        if let floor = self.floor?.ifNotEmpty() { line.append("Floor \(floor)")}
        if line.isEmpty == false {
            lines.append(line)
            line.removeAll()
        }
        
        if let streetNumber = self.streetNumberFirst?.ifNotEmpty() {
            line.append(streetNumber)

            if let streetNumberLast = self.streetNumberLast?.ifNotEmpty() {
                // FIXME: - This weird address line formatting stuff.
                line.removeAll()
                line.append("\(streetNumber)-\(streetNumberLast)")
            }
        }

        if let streetName   = self.streetName?.ifNotEmpty() { line.append(streetName) }
        if let streetType   = self.streetType?.ifNotEmpty() { line.append(streetType) }
        if let streetDirectional = self.streetDirectional?.ifNotEmpty() { line.append(streetDirectional) }
        if line.isEmpty == false {
            if includingName && commonName != nil && lines.isEmpty == false && line.joined(separator: " ") == commonName {
                _ = lines.remove(at: 0)
            }
            lines.append(line)
            line.removeAll()
        }
        
        if let suburb = self.suburb?.ifNotEmpty() { line.append(suburb) }
        if let city = self.county?.ifNotEmpty() { line.append(city) }
        if let state  = self.state?.ifNotEmpty() { line.append(state)  }
        if let postCode = self.postcode?.ifNotEmpty() { line.append(postCode) }
        
        if line.isEmpty == false { lines.append(line) }
        if let country = self.country?.ifNotEmpty() { lines.append([country]) }
        
        return lines.flatMap({ $0.isEmpty == false ? $0.joined(separator: " ") : nil })
    }
    
    func formatted(includingName: Bool = true, withLines: Bool = false) -> String? {
        return formattedLines(includingName: includingName)?.joined(separator: withLines ? "\n" : ", ")
    }

}
