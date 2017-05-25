//
//  FieldContact.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class FieldContact: NSObject, Serialisable {

    open let id: String
    
    open var remarks: String?
    
    open var contactMember: Member?
    open var secondaryContactMember: Member?
    open var contactDate: Date?
    open var status: String?
    open var areaType: String?
    
    // MARK: - ????
    open var contactLocation: String?
    open var locationResponseZone: String?
    open var neighbourhoodWatchArea: String?
    open var localGovernmentArea: String?
    
    open var contactDescriptions: [String]?
    open var reportingStation: String?
    
    public init(id: String) {
        self.id = id
        super.init()
    }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        
        remarks = unboxer.unbox(key: "remarks")
        
        contactMember = unboxer.unbox(key: "contactMember")
        secondaryContactMember = unboxer.unbox(key: "secondaryContactMember")
        contactDate = unboxer.unbox(key: "contactDate", formatter: FieldContact.dateTransformer)
        status = unboxer.unbox(key: "status")
        areaType = unboxer.unbox(key: "areaType")
        
        locationResponseZone = unboxer.unbox(key: "locationResponseZone")
        neighbourhoodWatchArea = unboxer.unbox(key: "neighbourhoodWatchArea")
        contactLocation = unboxer.unbox(key: "contactLocation")
        // Note contactDescription
        contactDescriptions = unboxer.unbox(key: "contactDescription")
        localGovernmentArea = unboxer.unbox(key: "localGovernmentArea")
        reportingStation = unboxer.unbox(key: "reportingStation")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
}
