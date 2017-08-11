//
//  Contact.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

@objc(MPLContact)
open class Contact: NSObject, Serialisable {

    open let id : String
    
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool?
    open var source: MPOLSource?
    
    open var type: String?
    open var subType: String?
    open var value: String?
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        
        self.id = id
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Contact.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Contact.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Contact.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Contact.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary")
        source = unboxer.unbox(key: "source")
        
        type = unboxer.unbox(key: "contactType")
        subType = unboxer.unbox(key: "contactSubType")
        value = unboxer.unbox(key: "value")
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
    
}
