//
//  BailOrder.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class BailOrder: Event {

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
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)
        
        hasOwnerUndertaking = unboxer.unbox(key: "hasOwnerUndertaking")
        reportingRequirements = unboxer.unbox(key: "reportingRequirements")
        firstReportDate = unboxer.unbox(key: "firstReportDate", formatter: BailOrder.dateTransformer)
        informantStation = unboxer.unbox(key: "informantStation")
        informantMember = unboxer.unbox(key: "informantMember")
        
        hearingDate = unboxer.unbox(key: "hearingDate", formatter: BailOrder.dateTransformer)
        postedDate = unboxer.unbox(key: "postedDate", formatter: BailOrder.dateTransformer)
        
        conditions = unboxer.unbox(key: "conditions")
        reportingToStation = unboxer.unbox(key: "reportingToStation")
        postedAt = unboxer.unbox(key: "postedAt")
        hearingLocation = unboxer.unbox(key: "hearingLocation")
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
