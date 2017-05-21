//
//  FamilyIncident.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class FamilyIncident: NSObject, Serialisable {
    
    open let id: String
    
    open var hasAssociatedReport: Bool?
    open var occurrenceDate: Date?
    open var startingPoint: String?
    open var incidentDescription: String?
    open var futureRisks: String?
    open var numberOfPreviousReports: Int?
    open var victimOtherPersonRelationship: String?
    open var victims: [ReportedPerson]?
    open var otherPersons: [ReportedPerson]?
    open var incidentPersons: [ReportedPerson]?
    open var numberOfInvolvedAdults: Int?
    open var numberOfInvolvedChildren0to4: Int?
    open var numberOfInvolvedChildren5to9: Int?
    open var numberOfInvolvedChildren10to16: Int?
    open var riskFactors: [RiskFactor]?
    open var riskManagementStrategies: [String]?
    open var reportEntries: [String]?
    
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
        
        hasAssociatedReport = unboxer.unbox(key: "hasAssociatedReport")
        // Note occuranceDate
        occurrenceDate = unboxer.unbox(key: "occuranceDate", formatter: FamilyIncident.dateTransformer)
        startingPoint = unboxer.unbox(key: "startingPoint")
        incidentDescription = unboxer.unbox(key: "description")
        futureRisks = unboxer.unbox(key: "futureRisks")
        numberOfPreviousReports = unboxer.unbox(key: "previousReports")
        victimOtherPersonRelationship = unboxer.unbox(key: "victimOtherPersonRelationship")
        victims = unboxer.unbox(key: "victims")
        otherPersons = unboxer.unbox(key: "otherPersons")
        incidentPersons = unboxer.unbox(key: "incidentPersons")
        numberOfInvolvedAdults = unboxer.unbox(key: "involvedAdults")
        numberOfInvolvedChildren0to4 = unboxer.unbox(key: "involvedChildren0to4")
        numberOfInvolvedChildren5to9 = unboxer.unbox(key: "involvedChildren5to9")
        numberOfInvolvedChildren10to16 = unboxer.unbox(key: "involvedChildren10to16")
        riskFactors = unboxer.unbox(key: "riskFactors")
        riskManagementStrategies = unboxer.unbox(key: "riskManagementStrategy")
        reportEntries = unboxer.unbox(key: "reportEntries")
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
