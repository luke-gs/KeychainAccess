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
