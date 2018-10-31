//
//  Contact.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import PublicSafetyKit

@objc(MPLContact)
open class Contact: IdentifiableDataModel {

    public enum ContactType: String, UnboxableEnum, Codable, CaseIterable {
        case phone = "home"
        case mobile = "mobile"
        case email = "email"

        public func localizedDescription() -> String {
            switch self {
            case .phone: return "Phone"
            case .mobile: return "Mobile"
            case .email: return "Email"
            }
        }

        public static func contactType(from LocalizedDescription: String) -> ContactType? {
            switch LocalizedDescription {
            case "Phone":
                return ContactType.phone
            case "Mobile":
                return ContactType.mobile
            case "Email":
                return ContactType.email
            default:
                return nil
            }
        }
    }

    public override init(id: String) {
        self.isSummary = false
        super.init(id: id)
    }

    // MARK: - Properties

    public var createdBy: String?
    public var dateCreated: Date?
    public var dateUpdated: Date?
    public var effectiveDate: Date?
    public var entityType: String?
    public var expiryDate: Date?
    public var isSummary: Bool = false
    public var jurisdiction: String?
    public var source: MPOLSource?
    public var subType: String?
    public var type: Contact.ContactType?
    public var updatedBy: String?
    public var value: String?

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {

        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Contact.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Contact.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Contact.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Contact.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        source = unboxer.unbox(key: "source")

        type = unboxer.unbox(key: "type")
        subType = unboxer.unbox(key: "contactSubType")
        value = unboxer.unbox(key: "value")
        jurisdiction = unboxer.unbox(key: "jurisdiction")

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case createdBy
        case dateCreated
        case dateUpdated
        case effectiveDate
        case entityType
        case expiryDate
        case isSummary
        case jurisdiction
        case source
        case subType
        case type
        case updatedBy
        case value
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        isSummary = try container.decode(Bool.self, forKey: .isSummary)
        jurisdiction = try container.decodeIfPresent(String.self, forKey: .jurisdiction)
        source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
        subType = try container.decodeIfPresent(String.self, forKey: .subType)
        type = try container.decodeIfPresent(Contact.ContactType.self, forKey: .type)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        value = try container.decodeIfPresent(String.self, forKey: .value)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdBy, forKey: CodingKeys.createdBy)
        try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
        try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
        try container.encode(entityType, forKey: CodingKeys.entityType)
        try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
        try container.encode(isSummary, forKey: CodingKeys.isSummary)
        try container.encode(jurisdiction, forKey: CodingKeys.jurisdiction)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(subType, forKey: CodingKeys.subType)
        try container.encode(type, forKey: CodingKeys.type)
        try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
        try container.encode(value, forKey: CodingKeys.value)
    }

}
