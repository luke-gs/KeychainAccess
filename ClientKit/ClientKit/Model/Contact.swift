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

    public enum ContactType: Int, UnboxableEnum {
        case phone  = 0
        case mobile = 1
        case email  = 2

        public func localizedDescription() -> String {
            switch self {
            case .phone:  return "Phone"
            case .mobile: return "Mobile"
            case .email:  return "Email"
            }
        }
    }
    
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
    
    open var type: Contact.ContactType?
    open var subType: String?
    open var value: String?
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(id: String = UUID().uuidString) {
        self.id = id
        self.isSummary = false

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
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        source = unboxer.unbox(key: "source")
        
        type = unboxer.unbox(key: "contactType")
        subType = unboxer.unbox(key: "contactSubType")
        value = unboxer.unbox(key: "value")
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!
        isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)

        super.init()

        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?

        if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }

        if let type = aDecoder.decodeObject(of: NSNumber.self, forKey: CodingKey.type.rawValue) {
            self.type = ContactType(rawValue: type.intValue)
        }

        subType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.subType.rawValue) as String?
        value = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.value.rawValue) as String?
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(Contact.modelVersion, forKey: CodingKey.version.rawValue)
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
        aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
        aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
        aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
        aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)

        if let type = type?.rawValue {
            aCoder.encode(NSNumber(value: type), forKey: CodingKey.subType.rawValue)
        }

        aCoder.encode(subType, forKey: CodingKey.subType.rawValue)
        aCoder.encode(value, forKey: CodingKey.value.rawValue)
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }

    // MARK: - Model Versionable
    open static var modelVersion: Int {
        return 0
    }
 
}

private enum CodingKey: String {
    case version
    case id
    case dateCreated
    case dateUpdated
    case createdBy
    case updatedBy
    case effectiveDate
    case expiryDate
    case entityType
    case isSummary
    case source
    case type
    case subType
    case value
}
