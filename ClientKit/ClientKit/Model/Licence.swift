//
//  Licence.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

@objc(MPLLicence)
open class Licence: NSObject, Serialisable {

    open let id: String
    
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool?
    open var source: MPOLSource?
    
    open var number: String?
    open var isSuspended: Bool?
    open var status: String?
    open var statusDescription: String?
    open var statusFromDate: Date?
    open var state: String?
    open var country: String?
    open var type: String?
    open var remarks: String?
    
    open var licenceClass: [LicenceClass]?
    open var conditions: [Condition]?
    open var restrictions: [Restriction]?

    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    fileprivate static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        
        self.id = id
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Licence.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Licence.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Licence.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Licence.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary")
        source = unboxer.unbox(key: "source")
        
        number = unboxer.unbox(key: "licenceNumber")
        isSuspended = unboxer.unbox(key: "isSuspended")
        status = unboxer.unbox(key: "status")
        statusDescription = unboxer.unbox(key: "statusDescription")
        statusFromDate = unboxer.unbox(key: "statusFromDate", formatter: Licence.dateTransformer)
        state = unboxer.unbox(key: "state")
        country = unboxer.unbox(key: "country")
        type = unboxer.unbox(key: "licenceType")
        remarks = unboxer.unbox(key: "remarks")
        
        licenceClass = unboxer.unbox(key: "licenceClass")
        conditions = unboxer.unbox(key: "conditions")
        restrictions = unboxer.unbox(key: "restrictions")
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.id = UUID().uuidString
//        MPLUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }

}


/// Licence Class
extension Licence {
    @objc(MPLLicenceClass)
    public class LicenceClass: NSObject, Serialisable {
        
        open let id: String
        
        open var dateCreated: Date?
        open var dateUpdated: Date?
        open var createdBy: String?
        open var updatedBy: String?
        open var effectiveDate: Date?
        open var expiryDate: Date?
        open var entityType: String?
        open var isSummary: Bool?
        open var source: MPOLSource?
        
        open var code: String?
        open var name: String?
        open var classDescription: String?
        
        open static var supportsSecureCoding: Bool {
            return true
        }
        
        public required init?(coder aDecoder: NSCoder) {
            MPLUnimplemented()
        }
        
        open func encode(with aCoder: NSCoder) {
            
        }
        
        public required init(id: String = UUID().uuidString) {
            self.id = id
            super.init()
        }
        
        public required init(unboxer: Unboxer) throws {
            
            guard let id: String = unboxer.unbox(key: "id") else {
                throw ParsingError.missingRequiredField
            }
            
            self.id = id
            
            dateCreated = unboxer.unbox(key: "dateCreated", formatter: Licence.dateTransformer)
            dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Licence.dateTransformer)
            createdBy = unboxer.unbox(key: "createdBy")
            updatedBy = unboxer.unbox(key: "updatedBy")
            effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Licence.dateTransformer)
            expiryDate = unboxer.unbox(key: "expiryDate", formatter: Licence.dateTransformer)
            entityType = unboxer.unbox(key: "entityType")
            isSummary = unboxer.unbox(key: "isSummary")
            source = unboxer.unbox(key: "source")
            
            code = unboxer.unbox(key: "code")
            name = unboxer.unbox(key: "name")
            classDescription = unboxer.unbox(key: "description")
            
            super.init()
        }
    }
    
    /// Licence Condition
    @objc(MPLCondition)
    public class Condition: NSObject, Serialisable {
        
        open let id: String
        
        open var dateCreated: Date?
        open var dateUpdated: Date?
        open var createdBy: String?
        open var updatedBy: String?
        open var effectiveDate: Date?
        open var expiryDate: Date?
        open var entityType: String?
        open var isSummary: Bool?
        open var source: MPOLSource?
        
        open var condition: String?
        
        open static var supportsSecureCoding: Bool {
            return true
        }
        
        public required init?(coder aDecoder: NSCoder) {
            MPLUnimplemented()
        }
        
        open func encode(with aCoder: NSCoder) {
            
        }
        
        public required init(id: String = UUID().uuidString) {
            self.id = id
            super.init()
        }
        
        public required init(unboxer: Unboxer) throws {
            
            guard let id: String = unboxer.unbox(key: "id") else {
                throw ParsingError.missingRequiredField
            }
            
            self.id = id
            
            dateCreated = unboxer.unbox(key: "dateCreated", formatter: Licence.dateTransformer)
            dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Licence.dateTransformer)
            createdBy = unboxer.unbox(key: "createdBy")
            updatedBy = unboxer.unbox(key: "updatedBy")
            effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Licence.dateTransformer)
            expiryDate = unboxer.unbox(key: "expiryDate", formatter: Licence.dateTransformer)
            entityType = unboxer.unbox(key: "entityType")
            isSummary = unboxer.unbox(key: "isSummary")
            source = unboxer.unbox(key: "source")
            
            condition = unboxer.unbox(key: "condition")
            
            super.init()
        }

        func displayValue() -> String? {
            var value = ""

            if let condition = self.condition {
                value += condition
            }

            if let fromDate = dateUpdated, let toDate = expiryDate {
                value += " - valid from: \(fromDate.wrap(dateFormatter: DateFormatter.shortDate)) to \(toDate.wrap(dateFormatter: DateFormatter.shortDate))"
            }

            return value
        }
    }
    
    /// Licence Restriction
    @objc(MPLRestriction)
    public class Restriction: NSObject, Serialisable {
        
        open let id: String
        
        open var dateCreated: Date?
        open var dateUpdated: Date?
        open var createdBy: String?
        open var updatedBy: String?
        open var effectiveDate: Date?
        open var expiryDate: Date?
        open var entityType: String?
        open var isSummary: Bool?
        open var source: MPOLSource?
        
        open var restriction: String?
        
        open static var supportsSecureCoding: Bool {
            return true
        }
        
        public required init?(coder aDecoder: NSCoder) {
            MPLUnimplemented()
        }
        
        open func encode(with aCoder: NSCoder) {
            
        }
        
        public required init(id: String = UUID().uuidString) {
            self.id = id
            super.init()
        }
        
        public required init(unboxer: Unboxer) throws {
            
            guard let id: String = unboxer.unbox(key: "id") else {
                throw ParsingError.missingRequiredField
            }
            
            self.id = id
            
            dateCreated = unboxer.unbox(key: "dateCreated", formatter: Licence.dateTransformer)
            dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Licence.dateTransformer)
            createdBy = unboxer.unbox(key: "createdBy")
            updatedBy = unboxer.unbox(key: "updatedBy")
            effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Licence.dateTransformer)
            expiryDate = unboxer.unbox(key: "expiryDate", formatter: Licence.dateTransformer)
            entityType = unboxer.unbox(key: "entityType")
            isSummary = unboxer.unbox(key: "isSummary")
            source = unboxer.unbox(key: "source")
            
            restriction = unboxer.unbox(key: "restriction")
            
            super.init()
        }
    }
    
}
