//
//  Address.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

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
    open var isSummary: Bool?
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
        isSummary = unboxer.unbox(key: "isSummary")
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
        MPLUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        
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
