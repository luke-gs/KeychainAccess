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
    
    open var addressType: String?
    open var postalContainer: String?
    open var floor: String?
    open var unit: String?
    open var streetNumber: String?
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
        streetNumber = unboxer.unbox(key: "streetNumber")
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
    }
    
    open override func encode(with aCoder: NSCoder) {
        MPLUnimplemented()
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
        
        if let streetNumber = self.streetNumber?.ifNotEmpty() { line.append(streetNumber) }
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
