//
//  BailOrder.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class BailOrder: NSObject, Serialisable {

    open let id: String
    
    open var hasOwnerUndertaking: Bool?
    open var reportingRequirements: [String]?
    open var firstReportDate: Date?
    open var informantStation: String?
    open var informantMember: String?
    
    open var hearingDate: Date?
    open var postedDate: Date?
    
    // MARK: - ???
    open var conditions: [String]?
    open var reportingToStation: String?
    open var postedAt: String?
    open var hearingLocation: String?
    
    
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
        
        hasOwnerUndertaking = unboxer.unbox(key: "hasOwnerUndertaking")
        reportingRequirements = unboxer.unbox(key: "bailReportingRequirements")
        firstReportDate = unboxer.unbox(key: "firstReportDate", formatter: BailOrder.dateTransformer)
        informantStation = unboxer.unbox(key: "informantStation")
        informantMember = unboxer.unbox(key: "informantMember")
        
        hearingDate = unboxer.unbox(key: "bailHearingDate", formatter: BailOrder.dateTransformer)
        postedDate = unboxer.unbox(key: "bailPostedDate", formatter: BailOrder.dateTransformer)
        
        conditions = unboxer.unbox(key: "bailConditions")
        reportingToStation = unboxer.unbox(key: "reportingToStation")
        postedAt = unboxer.unbox(key: "bailPostedAt")
        hearingLocation = unboxer.unbox(key: "bailHearingLocation")
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
