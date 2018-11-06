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
open class Alert: IdentifiableDataModel {

    public enum Level: Int, UnboxableEnum, Codable {

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

    public init(id: String, level: Alert.Level) {
        self.level = level
        super.init(id: id)
    }

    // MARK: - Properties

    public var createdBy: String?
    public var dateCreated: Date?
    public var dateUpdated: Date?
    public var details: String?
    public var effectiveDate: Date?
    public var entityType: String?
    public var expiryDate: Date?
    public var isSummary: Bool = false
    public var jurisdiction: String?
    public var level: Alert.Level?
    public var source: MPOLSource?
    public var title: String?
    public var updatedBy: String?

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    required public init(unboxer: Unboxer) throws {

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

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case createdBy
        case dateCreated
        case dateUpdated
        case details
        case effectiveDate
        case entityType
        case expiryDate
        case isSummary
        case jurisdiction
        case level
        case source
        case title
        case updatedBy
        case version
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
        details = try container.decodeIfPresent(String.self, forKey: .details)
        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        isSummary = try container.decode(Bool.self, forKey: .isSummary)
        jurisdiction = try container.decodeIfPresent(String.self, forKey: .jurisdiction)
        level = try container.decodeIfPresent(Level.self, forKey: .level)
        source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdBy, forKey: CodingKeys.createdBy)
        try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
        try container.encode(details, forKey: CodingKeys.details)
        try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
        try container.encode(entityType, forKey: CodingKeys.entityType)
        try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
        try container.encode(isSummary, forKey: CodingKeys.isSummary)
        try container.encode(jurisdiction, forKey: CodingKeys.jurisdiction)
        try container.encode(level, forKey: CodingKeys.level)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(title, forKey: CodingKeys.title)
        try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
    }
}

extension Alert.Level: Pickable {

    public var title: StringSizable? {
        return self.localizedDescription()
    }

    public var subtitle: StringSizable? {
        return nil
    }

}

extension Alert.Level: Comparable {

    public static func < (lhs: Alert.Level, rhs: Alert.Level) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
