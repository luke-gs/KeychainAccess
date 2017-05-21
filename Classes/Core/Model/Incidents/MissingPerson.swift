//
//  MissingPerson.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class MissingPerson: NSObject, Serialisable {

    open let id: String
    
    open var subincidentID: String?
    open var missingFromDate: Date?
    open var reportedDate: Date?
    open var fullName: String?
    
    open var foundDate: Date?
    open var declarationDate: Date?
    open var lastKnownLocation: Address?
    
    open var physicalHealthDescription: String?
    open var mentalHeathDescription: String?
    open var reportingStation: String?
    open var probableCause: String?
    
    open var phoneNumbers: [TelephoneNumber]?
    
    // MARK: - ???
    open var locatingMemberId: String?
    open var locatingMemberOrganisationalUnit: String?
    
    
    open var missingPersonReports: [String]?
    open var probableDestination: String?
    
    public init(id: String) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
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
