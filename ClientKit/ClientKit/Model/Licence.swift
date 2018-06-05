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
    open var isSummary: Bool = false
    open var source: MPOLSource?
    
    open var number: String?
    open var isSuspended: Bool = false
    open var status: String?
    open var statusDescription: String?
    open var statusFromDate: Date?
    open var state: String?
    open var country: String?
    open var type: String?
    open var remarks: String?
    
    open var licenceClasses: [LicenceClass]?

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
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        source = unboxer.unbox(key: "source")
        
        number = unboxer.unbox(key: "licenceNumber")
        isSuspended = unboxer.unbox(key: "isSuspended") ?? false
        status = unboxer.unbox(key: "status")
        statusDescription = unboxer.unbox(key: "statusDescription")
        statusFromDate = unboxer.unbox(key: "statusFromDate", formatter: Licence.dateTransformer)
        state = unboxer.unbox(key: "state")
        country = unboxer.unbox(key: "country")
        type = unboxer.unbox(key: "licenceType")
        remarks = unboxer.unbox(key: "remarks")
        
        licenceClasses = unboxer.unbox(key: "classes")
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.id = (aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.id.rawValue) as String?)!

        super.init()

        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.dateUpdated.rawValue) as Date?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.effectiveDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.expiryDate.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.updatedBy.rawValue) as String?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.entityType.rawValue) as String?
        isSummary = aDecoder.decodeBool(forKey: CodingKeys.isSummary.rawValue)

        if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }

        number = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.number.rawValue) as String?
        isSuspended = aDecoder.decodeBool(forKey: CodingKeys.isSuspended.rawValue)
        status = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.status.rawValue) as String?
        statusDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.statusDescription.rawValue) as String?
        statusFromDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.statusFromDate.rawValue) as Date?
        state = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.state.rawValue) as String?
        country = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.country.rawValue) as String?
        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue) as String?
        remarks = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.remarks.rawValue) as String?

        licenceClasses = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKeys.licenceClasses.rawValue) as? [LicenceClass]

    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(Licence.modelVersion, forKey: CodingKeys.version.rawValue)
        aCoder.encode(id, forKey: CodingKeys.id.rawValue)
        aCoder.encode(dateCreated, forKey: CodingKeys.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: CodingKeys.dateUpdated.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKeys.expiryDate.rawValue)
        aCoder.encode(createdBy, forKey: CodingKeys.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: CodingKeys.updatedBy.rawValue)
        aCoder.encode(entityType, forKey: CodingKeys.entityType.rawValue)
        aCoder.encode(isSummary, forKey: CodingKeys.isSummary.rawValue)
        aCoder.encode(source?.rawValue, forKey: CodingKeys.source.rawValue)

        aCoder.encode(number, forKey: CodingKeys.number.rawValue)
        aCoder.encode(isSuspended, forKey: CodingKeys.isSuspended.rawValue)
        aCoder.encode(status, forKey: CodingKeys.status.rawValue)
        aCoder.encode(statusDescription, forKey: CodingKeys.statusDescription.rawValue)
        aCoder.encode(statusFromDate, forKey: CodingKeys.statusFromDate.rawValue)
        aCoder.encode(state, forKey: CodingKeys.state.rawValue)
        aCoder.encode(country, forKey: CodingKeys.country.rawValue)
        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
        aCoder.encode(remarks, forKey: CodingKeys.remarks.rawValue)

        aCoder.encode(licenceClasses, forKey: CodingKeys.licenceClasses.rawValue)

    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }

    // MARK: - Model Versionable
    open static var modelVersion: Int {
        return 0
    }

    private enum CodingKeys: String, CodingKey {
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

        case licenceClasses = "classes"
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
        open var isSummary: Bool = false
        open var source: MPOLSource?
        
        open var code: String?
        open var name: String?
        open var classDescription: String?
        open var conditions: [Condition]?
        
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
            isSummary = unboxer.unbox(key: "isSummary") ?? false
            source = unboxer.unbox(key: "source")
            
            code = unboxer.unbox(key: "code")
            name = unboxer.unbox(key: "name")
            classDescription = unboxer.unbox(key: "description")
            conditions = unboxer.unbox(key: "conditions")
            
            super.init()
        }

        public required init?(coder aDecoder: NSCoder) {
            self.id = (aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String?)!

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
            conditions = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKeys.status.rawValue) as? [Condition]

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
            aCoder.encode(conditions, forKey: CodingKey.conditions.rawValue)
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
            case conditions
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
        open var isSummary: Bool = false
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
            isSummary = unboxer.unbox(key: "isSummary") ?? false
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
                value += " - valid from: \(fromDate.wrap(dateFormatter: DateFormatter.preferredDateStyle)) to \(toDate.wrap(dateFormatter: DateFormatter.preferredDateStyle))"
            }

            return value
        }

        public required init?(coder aDecoder: NSCoder) {
            self.id = (aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String?)!

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
    
}
