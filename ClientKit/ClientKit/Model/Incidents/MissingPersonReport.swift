//
//  MissingPersonReport.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

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
        super.init(coder: aDecoder)

        subincidentID = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.subincidentID.rawValue) as String?
        missingFromDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.missingFromDate.rawValue) as Date?
        reportedDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.reportedDate.rawValue) as Date?
        fullName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.fullName.rawValue) as String?
        foundDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.foundDate.rawValue) as Date?
        declarationDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.declarationDate.rawValue) as Date?
        lastKnownLocation = aDecoder.decodeObject(of: Address.self, forKey: CodingKey.lastKnownLocation.rawValue)
        physicalHealthDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.physicalHealthDescription.rawValue) as String?
        mentalHeathDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.mentalHealthDescription.rawValue) as String?
        probableCause = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.probableCause.rawValue) as String?

        phoneNumbers = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.phoneNumbers.rawValue) as? [TelephoneNumber]
        reportingStation = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.reportingStation.rawValue) as String?
        locatingMemberID = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.locatingMemberID.rawValue) as String?
        locatingMemberOrganisationalUnit = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.locatingMemberOrganisationalUnit.rawValue) as String?
        missingPersonReports = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.missingPersonReports.rawValue) as? [String]
        probableDestination = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.probableDestination.rawValue) as String?
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(subincidentID, forKey: CodingKey.subincidentID.rawValue)
        aCoder.encode(missingFromDate, forKey: CodingKey.missingFromDate.rawValue)
        aCoder.encode(reportedDate, forKey: CodingKey.reportedDate.rawValue)
        aCoder.encode(fullName, forKey: CodingKey.fullName.rawValue)
        aCoder.encode(foundDate, forKey: CodingKey.foundDate.rawValue)
        aCoder.encode(declarationDate, forKey: CodingKey.declarationDate.rawValue)
        aCoder.encode(lastKnownLocation, forKey: CodingKey.lastKnownLocation.rawValue)
        aCoder.encode(physicalHealthDescription, forKey: CodingKey.physicalHealthDescription.rawValue)
        aCoder.encode(mentalHeathDescription, forKey: CodingKey.mentalHealthDescription.rawValue)
        aCoder.encode(probableCause, forKey: CodingKey.probableCause.rawValue)
        aCoder.encode(phoneNumbers, forKey: CodingKey.phoneNumbers.rawValue)
        aCoder.encode(reportingStation, forKey: CodingKey.reportingStation.rawValue)
        aCoder.encode(locatingMemberID, forKey: CodingKey.locatingMemberID.rawValue)
        aCoder.encode(locatingMemberOrganisationalUnit, forKey: CodingKey.locatingMemberOrganisationalUnit.rawValue)
        aCoder.encode(missingPersonReports, forKey: CodingKey.missingPersonReports.rawValue)
        aCoder.encode(probableDestination, forKey: CodingKey.probableDestination.rawValue)
    }

    private enum CodingKey: String {
        case subincidentID
        case missingFromDate
        case reportedDate
        case fullName
        case foundDate
        case declarationDate
        case lastKnownLocation
        case physicalHealthDescription
        case mentalHealthDescription
        case probableCause
        case phoneNumbers
        case reportingStation
        case locatingMemberID
        case locatingMemberOrganisationalUnit
        case missingPersonReports
        case probableDestination
    }
}
