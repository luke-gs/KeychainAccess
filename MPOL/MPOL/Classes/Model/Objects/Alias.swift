//
//  Alias.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import Foundation
import PublicSafetyKit
import Unbox

@objc(MPLAlias)
open class Alias: NSObject, Serialisable {

    public static var supportsSecureCoding: Bool {
        return true
    }

    public static var modelVersion: Int { return 0 }

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
    open var jurisdiction: String?

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
        jurisdiction = unboxer.unbox(key: "jurisdiction")
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        id = (aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String?)!

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
        jurisdiction = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.jurisdiction.rawValue) as String?
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
        aCoder.encode(jurisdiction, forKey: CodingKey.jurisdiction.rawValue)
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
        case jurisdiction
    }
}
