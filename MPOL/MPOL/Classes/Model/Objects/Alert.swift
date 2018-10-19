//
//  Alert.swift
//  
//
//  Created by Herli Halim on 28/3/17.
//
//

import PublicSafetyKit
import Unbox

@objc(MPLAlert)
open class Alert: NSObject, Serialisable {

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public enum Level: Int, UnboxableEnum {

        case low    = 0
        case medium = 1
        case high   = 2

        public static let allCases: [Level] = [.low, .medium, .high]

        public var color: UIColor? {
            switch self {
            case .high: return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
            case .medium: return #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
            case .low: return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            }
        }

        public func localizedDescription() -> String? {
            switch self {
            case .high: return NSLocalizedString("High", comment: "Alert Level Title")
            case .medium: return NSLocalizedString("Medium", comment: "Alert Level Title")
            case .low: return NSLocalizedString("Low", comment: "Alert Level Title")
            }
        }

        public static var all: [Level] = [.high, .medium, .low]
    }

    open var id: String
    open var level: Alert.Level?

    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool = false

    open var source: MPOLSource?
    open var title: String?
    open var details: String?
    open var jurisdiction: String?

    // MARK: - Equality

    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Alert {
            return object.id == self.id
        }
        return super.isEqual(object)
    }

    // MARK: - Temp

    public init(id: String, level: Alert.Level) {
        self.id = id
        self.level = level

        super.init()
    }

    // MARK: - Unboxable

    required public init(unboxer: Unboxer) throws {

        guard let id: String = unboxer.unbox(key: "id") else {
                throw ParsingError.missingRequiredField
        }

        self.id       = id
        self.level    = unboxer.unbox(key: "alertLevel")

        dateCreated   = unboxer.unbox(key: "dateCreated", formatter: Alert.dateTransformer)
        dateUpdated   = unboxer.unbox(key: "dateLastUpdated", formatter: Alert.dateTransformer)
        createdBy     = unboxer.unbox(key: "createdBy")
        updatedBy     = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Alert.dateTransformer)
        expiryDate    = unboxer.unbox(key: "expiryDate", formatter: Alert.dateTransformer)
        entityType    = unboxer.unbox(key: "entityType")
        isSummary     = unboxer.unbox(key: "isSummary") ?? false

        source        = unboxer.unbox(key: "source")
        title         = unboxer.unbox(key: "title")
        details       = unboxer.unbox(key: "remarks")
        jurisdiction  = unboxer.unbox(key: "jurisdiction")

        super.init()
    }

    // MARK: - NSSecureCoding

    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String? else {
            return nil
        }

        self.id = id
        isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)

        super.init()

        title = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.title.rawValue) as String?
        details = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.details.rawValue) as String?
        jurisdiction = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.jurisdiction.rawValue) as String?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?

        if aDecoder.containsValue(forKey: CodingKey.level.rawValue),
            let level = Level(rawValue: aDecoder.decodeInteger(forKey: CodingKey.level.rawValue)) {
            self.level = level
        }

        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?

        if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(Alert.modelVersion, forKey: CodingKey.version.rawValue)
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(jurisdiction, forKey: CodingKey.jurisdiction.rawValue)
        if let level = level?.rawValue {
            aCoder.encode(level, forKey: CodingKey.level.rawValue)
        }

        aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
        aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
        aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
        aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
        aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)
    }

    public static var supportsSecureCoding: Bool {
        return true
    }

    // MARK: - Model Versionable
    public static var modelVersion: Int {
        return 0
    }
}

extension Alert.Level: Pickable {

    public var title: String? {
        return self.localizedDescription()
    }

    public var subtitle: String? {
        return nil
    }

}

extension Alert.Level: Comparable {

    public static func < (lhs: Alert.Level, rhs: Alert.Level) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

private enum CodingKey: String {
    case version
    case id
    case level
    case title
    case details
    case jurisdiction
    case effectiveDate
    case dateCreated
    case dateUpdated
    case createdBy
    case updatedBy
    case expiryDate
    case entityType
    case isSummary
    case source
}
