//
//  Address.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

@objc(MPLAddress)
open class Address: NSObject, Serialisable {


    open let id : String
    
    open var commonName : String?
    open var country : String?
    
    open var floor : String?
    
    open var postcode : String?
    
    open var state : String?
    open var streetDirectional : String?
    open var streetName : String?
    open var streetNumber : String?
    open var streetType : String?
    open var suburb : String?
    open var unitNumber : String?
    
    open var reportDate: Date?
    
    open var type: String?
    open var city: String?
    
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
        
        commonName = unboxer.unbox(key: "commonName")
        country = unboxer.unbox(key: "country")
        floor = unboxer.unbox(key: "floor")
        postcode = unboxer.unbox(key: "postCode")
        state = unboxer.unbox(key: "state")
        streetDirectional = unboxer.unbox(key: "streetDirectional")
        streetName = unboxer.unbox(key: "streetName")
        streetType = unboxer.unbox(key: "streetType")
        suburb = unboxer.unbox(key: "suburb")
        unitNumber = unboxer.unbox(key: "unitNumber")
        streetNumber = unboxer.unbox(key: "streetNumber")
        
        reportDate = unboxer.unbox(key: "reportedDate", formatter: ISO8601DateTransformer.shared)
        type = unboxer.unbox(key: "addressType")
        city = unboxer.unbox(key: "city")
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
    
    
    // MARK: - Temp Formatters
    
    func formattedLines(includingName: Bool = true) -> [String]? {
        var lines: [[String]] = []
        
        if includingName, let name = commonName {
            lines.append([name])
        }
// TODO       if let postalBox = postalBox {
//            lines.append([postalBox])
//        }
        
        var line: [String] = []
        if let unitNumber = self.unitNumber?.ifNotEmpty() { line.append("Unit \(unitNumber)") }
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
        if let city = self.city?.ifNotEmpty() { line.append(city) }
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
