//
//  MissingPersonReport.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class MissingPersonReport: Event {
    
    open var subincidentID: String?
    open var missingFromDate: Date?
    open var reportedDate: Date?
    open var fullName: String?
    
    open var foundDate: Date?
    open var declarationDate: Date?
    open var lastKnownLocation: Address?
    
    open var physicalHealthDescription: String?
    open var mentalHeathDescription: String?
    open var probableCause: String?
    
    open var phoneNumbers: [TelephoneNumber]?
    
    // MARK: - ???
    open var reportingStation: String?
    open var locatingMemberID: String?
    open var locatingMemberOrganisationalUnit: String?
    
    open var missingPersonReports: [String]?
    open var probableDestination: String?
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)
        
        subincidentID = unboxer.unbox(key: "subincidentId")
        missingFromDate = unboxer.unbox(key: "missingFrom", formatter: MissingPersonReport.dateTransformer)
        reportedDate = unboxer.unbox(key: "reported", formatter: MissingPersonReport.dateTransformer)
        fullName = unboxer.unbox(key: "fullName")
        
        foundDate = unboxer.unbox(key: "found", formatter: MissingPersonReport.dateTransformer)
        // Note delcaration
        declarationDate = unboxer.unbox(key: "delcaration", formatter: MissingPersonReport.dateTransformer)
        lastKnownLocation = unboxer.unbox(key: "lastKnownLocation")
        
        physicalHealthDescription = unboxer.unbox(key: "physicalHealth")
        mentalHeathDescription = unboxer.unbox(key: "mentalHeathDescription")
        reportingStation = unboxer.unbox(key: "reportingStation")
        probableCause = unboxer.unbox(key: "probableCause")
        
        phoneNumbers = unboxer.unbox(key: "phoneNumbers")
        
        locatingMemberID = unboxer.unbox(key: "locatingMemberId")
        locatingMemberOrganisationalUnit = unboxer.unbox(key: "locatingMemberOrganisationalUnit")
        
        // Note missingPersonReport
        missingPersonReports = unboxer.unbox(key: "missingPersonReport")
        probableDestination = unboxer.unbox(key: "probableDestination")

    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    public required init(id: String) {
        super.init(id: id)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        MPLUnimplemented()
    }
}
