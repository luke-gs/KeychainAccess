//
//  Alias.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import Foundation
import MPOLKit
import Unbox


@objc(MPLAlias)
open class Alias: NSObject, Serialisable {
    
    public static var supportsSecureCoding: Bool {
        return true
    }

    open static var modalVersion: Int { return 0 }
    
    open var id: String
    
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool = false
    open var source: MPOLSource?
    
    open var type: String?
    open var firstName: String?
    open var lastName: String?
    open var middleNames: String?
    open var dateOfBirth: Date?
    open var ethnicity: String?
    open var title: String?
    
    public required init(id: String = UUID().uuidString) {
        self.id = id

        super.init()
    }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Alias.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Alias.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Alias.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Alias.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        source = unboxer.unbox(key: "source")

        type = unboxer.unbox(key: "nameType")
        firstName = unboxer.unbox(key: "givenName")
        middleNames = unboxer.unbox(key: "middleNames")
        lastName = unboxer.unbox(key: "familyName")
        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: Alias.dateTransformer)
        ethnicity = unboxer.unbox(key: "ethnicity")
        title = unboxer.unbox(key: "title")
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!

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

        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.type.rawValue) as String?
        firstName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.firstName.rawValue) as String?
        middleNames = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.middleNames.rawValue) as String?
        lastName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.lastName.rawValue) as String?
        dateOfBirth = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateOfBirth.rawValue) as Date?
        ethnicity = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.ethnicity.rawValue) as String?
        title = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.title.rawValue) as String?
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(Alias.modelVersion, forKey: CodingKey.version.rawValue)

        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
        aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
        aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
        aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
        aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)

        aCoder.encode(type, forKey: CodingKey.type.rawValue)
        aCoder.encode(firstName, forKey: CodingKey.firstName.rawValue)
        aCoder.encode(middleNames, forKey: CodingKey.middleNames.rawValue)
        aCoder.encode(lastName, forKey: CodingKey.lastName.rawValue)
        aCoder.encode(dateOfBirth, forKey: CodingKey.dateOfBirth.rawValue)
        aCoder.encode(ethnicity, forKey: CodingKey.ethnicity.rawValue)
        aCoder.encode(title, forKey: CodingKey.title.rawValue)
    }
    
    
    // TEMP?
    open var formattedName: String? {
        var formattedName: String = ""
        
        if let lastName = self.lastName?.ifNotEmpty() {
            formattedName += lastName
            
            if firstName?.isEmpty ?? true == false || middleNames?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = self.firstName?.ifNotEmpty() {
            formattedName += givenName
            
            if middleNames?.isEmpty ?? true == false {
                formattedName += " "
            }
        }
        
        if let firstMiddleNameInitial = middleNames?.first {
            formattedName.append(firstMiddleNameInitial)
            formattedName += "."
        }
        
        return formattedName

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
        case firstName
        case middleNames
        case lastName
        case dateOfBirth
        case ethnicity
        case title
    }
}
