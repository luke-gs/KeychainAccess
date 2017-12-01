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
        self.id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!

        super.init()

        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?
        isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)

        if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }

        number = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.number.rawValue) as String?
        isSuspended = aDecoder.decodeBool(forKey: CodingKey.isSuspended.rawValue)
        status = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.status.rawValue) as String?
        statusDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.statusDescription.rawValue) as String?
        statusFromDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.statusFromDate.rawValue) as Date?
        state = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.state.rawValue) as String?
        country = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.country.rawValue) as String?
        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.type.rawValue) as String?
        remarks = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.remarks.rawValue) as String?

        licenceClass = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.status.rawValue) as? [LicenceClass]
        conditions = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.status.rawValue) as? [Condition]
        restrictions = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.status.rawValue) as? [Restriction]
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(Licence.modelVersion, forKey: CodingKey.version.rawValue)
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
        aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
        aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
        aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
        aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)

        aCoder.encode(number, forKey: CodingKey.number.rawValue)
        aCoder.encode(isSuspended, forKey: CodingKey.isSuspended.rawValue)
        aCoder.encode(status, forKey: CodingKey.status.rawValue)
        aCoder.encode(statusDescription, forKey: CodingKey.statusDescription.rawValue)
        aCoder.encode(statusFromDate, forKey: CodingKey.statusFromDate.rawValue)
        aCoder.encode(state, forKey: CodingKey.state.rawValue)
        aCoder.encode(country, forKey: CodingKey.country.rawValue)
        aCoder.encode(type, forKey: CodingKey.type.rawValue)
        aCoder.encode(remarks, forKey: CodingKey.remarks.rawValue)

        aCoder.encode(licenceClass, forKey: CodingKey.licenceClass.rawValue)
        aCoder.encode(conditions, forKey: CodingKey.conditions.rawValue)
        aCoder.encode(restrictions, forKey: CodingKey.restrictions.rawValue)
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }

    // MARK: - Model Versionable
    open static var modelVersion: Int {
        return 0
    }

    private enum CodingKey: String {
        case version
        case id
        case dateCreated
        case dateUpdated
        case createdBy
        case updatedBy
        case expiryDate
        case effectiveDate
        case entityType
        case isSummary
        case source

        case number
        case isSuspended
        case status
        case statusDescription
        case statusFromDate
        case state
        case country
        case type
        case remarks

        case licenceClass
        case conditions
        case restrictions
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

        open static var modelVersion: Int {
            return 0
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

        public required init?(coder aDecoder: NSCoder) {
            self.id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!

            super.init()

            dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
            dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
            effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
            expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
            createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
            updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
            entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?
            isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)

            if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
                self.source = MPOLSource(rawValue: source)
            }

            classDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.classDescription.rawValue) as String?
        }

        open func encode(with aCoder: NSCoder) {
            aCoder.encode(LicenceClass.modelVersion, forKey: CodingKey.version.rawValue)
            aCoder.encode(id, forKey: CodingKey.id.rawValue)
            aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
            aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
            aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
            aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
            aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
            aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
            aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
            aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)
            aCoder.encode(classDescription, forKey: CodingKey.classDescription.rawValue)
        }

        private enum CodingKey: String {
            case version
            case id
            case dateCreated
            case dateUpdated
            case createdBy
            case updatedBy
            case expiryDate
            case effectiveDate
            case entityType
            case isSummary
            case source
            case classDescription
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

        open static var modelVersion: Int {
            return 0
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

        public required init?(coder aDecoder: NSCoder) {
            self.id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!

            super.init()

            dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
            dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
            effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
            expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
            createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
            updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
            entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?
            isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)

            if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
                self.source = MPOLSource(rawValue: source)
            }

            condition = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.condition.rawValue) as String?
        }

        open func encode(with aCoder: NSCoder) {
            aCoder.encode(Condition.modelVersion, forKey: CodingKey.version.rawValue)
            aCoder.encode(id, forKey: CodingKey.id.rawValue)
            aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
            aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
            aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
            aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
            aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
            aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
            aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
            aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)
            aCoder.encode(condition, forKey: CodingKey.condition.rawValue)
        }

        private enum CodingKey: String {
            case version
            case id
            case dateCreated
            case dateUpdated
            case createdBy
            case updatedBy
            case expiryDate
            case effectiveDate
            case entityType
            case isSummary
            case source
            case condition
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

        open static var modelVersion: Int {
            return 0
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

        public required init?(coder aDecoder: NSCoder) {
            self.id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!

            super.init()

            dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
            dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
            effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
            expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
            createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
            updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
            entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?
            isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)

            if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
                self.source = MPOLSource(rawValue: source)
            }

            restriction = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.restriction.rawValue) as String?
        }

        open func encode(with aCoder: NSCoder) {
            aCoder.encode(Restriction.modelVersion, forKey: CodingKey.version.rawValue)
            aCoder.encode(id, forKey: CodingKey.id.rawValue)
            aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
            aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
            aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
            aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
            aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
            aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
            aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
            aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)
            aCoder.encode(restriction, forKey: CodingKey.restriction.rawValue)
        }

        private enum CodingKey: String {
            case version
            case id
            case dateCreated
            case dateUpdated
            case createdBy
            case updatedBy
            case expiryDate
            case effectiveDate
            case entityType
            case isSummary
            case source
            case restriction
        }
    }
    
}
